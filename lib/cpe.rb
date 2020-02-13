# frozen_string_literal: true

require 'cpe/version'
require 'cpe/version_wildcard'
require 'pry'
require 'citrus'

Citrus.load(File.expand_path('cpe/wfn', File.dirname(__FILE__)))
Citrus.load(File.expand_path('cpe/cpe23', File.dirname(__FILE__)))

# Implementation of CPE 2.3: https://cpe.mitre.org/specification
class CPE
  # The part attribute SHALL have one of these three string values:
  # The value "a", when the WFN is for a class of applications.
  # The value "o", when the WFN is for a class of operating systems.
  # The value "h", when the WFN is for a class of hardware devices.
  attr_accessor :part

  # Values for this attribute SHOULD describe or identify the person or
  # organization that manufactured or created the product. Values for this
  # attribute SHOULD be selected from an attribute-specific valid-values list,
  # which MAY be defined by other specifications that utilize this
  # specification. Any character string meeting the requirements for WFNs (cf.
  # 5.3.2) MAY be specified as the value of the attribute.
  attr_accessor :vendor

  # Values for this attribute SHOULD describe or identify the most common and
  # recognizable title or name of the product. Values for this attribute SHOULD
  # be selected from an attribute-specific valid-values list, which MAYbe
  # defined by other specifications that utilize this specification. Any
  # character string meeting the requirements for WFNs(cf. 5.3.2) MAY be
  # specified as the value of the attribute.
  attr_accessor :product

  # Values for this attribute SHOULD be vendor-specific alphanumeric strings
  # characterizing the particular release version of the product. Version
  # information SHOULD be copied directly (with escaping of printable
  # non-alphanumeric characters as required) from discoverable data and SHOULD
  # NOT be truncated or otherwise modified. Any character string meeting the
  # requirements for WFNs (cf. 5.3.2) MAY be specified as the value of the
  # attribute.
  attr_accessor :version

  # Values for this attribute SHOULD be vendor-specific alphanumeric strings
  # characterizing the particular update, service pack, or point release of the
  # product.Values for this attribute SHOULD be selected from an
  # attribute-specific valid-values list, which MAYbe defined by other
  # specifications that utilize this specification. Any character string meeting
  # the requirements for WFNs (cf. 5.3.2) MAYbe specified as the value of the
  # attribute.
  attr_accessor :update

  # The edition attribute isconsidered deprecatedin this specification, and it
  # SHOULD be assigned the logical value ANY except where required for backward
  # compatibility with version 2.2 of the CPE specification.This attribute is
  # referred to as the "legacyedition" attribute. If this attribute is used,
  # values for this attribute SHOULD capture edition-related terms applied by
  # the vendor to the product. Values for this attribute SHOULD be selected from
  # an attribute-specific valid-values list, which MAYbe defined by other
  # specifications that utilize this specification. Any character string meeting
  # the requirements for WFNs (cf. 5.3.2) MAY be specified as the value of the
  # attribute.
  attr_accessor :edition

  # Values for thisattribute SHALL be valid language tagsas defined by
  # [RFC5646], and SHOULD be used to define the language supported in the user
  # interface of the product being described.Although any valid language tag MAY
  # be used, only tags containing language and region codes SHOULD be used.
  attr_accessor :language

  # Values for this attribute SHOULD characterize how the product is tailored to
  # a particular market or class of end users. Values for this attribute SHOULD
  # be selected from an attribute-specific valid-values list, which MAYbe
  # defined by other specifications that utilize this specification. Any
  # character string meeting the requirements for WFNs(cf. 5.3.2) MAYbe
  # specified as the value of the attribute.
  attr_accessor :sw_edition

  # Values for this attribute SHOULDcharacterize the software computing
  # environment within which the product operates.Values for this attribute
  # SHOULD be selected from an attribute-specific valid-values list, which MAYbe
  # defined by other specifications that utilize this specification. Any
  # character string meeting the requirements for WFNs(cf. 5.3.2) MAYbe
  # specified as the value of the attribute.
  attr_accessor :target_sw

  # Valuesfor this attribute SHOULD characterize the instruction set
  # architecture (e.g., x86) on which the product being described or identified
  # by the WFN operates. Bytecode-intermediate languages, such as Java bytecode
  # for the Java Virtual Machine or Microsoft Common Intermediate Language for
  # the Common Language Runtime virtual machine, SHALL be considered instruction
  # set architectures. Values for this attribute SHOULD be selected from an
  # attribute-specific valid-values list, which MAY be defined by other
  # specifications that utilize this specification. Any character string meeting
  # the requirements for WFNs(cf. 5.3.2) MAY be specified as the value of the
  # attribute.
  attr_accessor :target_hw

  # Values for this attribute SHOULD capture any other general descriptive or
  # identifying information which is vendor-or product-specific and which does
  # not logically fit in any other attribute value. Values SHOULD NOT be used
  # for storing instance-specific data (e.g., globally-unique identifiers or
  # Internet Protocol addresses).Values for this attribute SHOULD be selected
  # from a valid-values list that is refined over time; this list MAYbe defined
  # by other specifications that utilize this specification. Any character
  # string meeting the requirements for WFNs (cf. 5.3.2) MAYbe specified as the
  # value of the attribute.
  attr_accessor :other

  def initialize(part: nil, vendor: nil, product: nil, version: nil,
                 update: nil, edition: nil, language: nil, sw_edition: nil,
                 target_sw: nil, target_hw: nil, other: nil)
    @part = part
    @vendor = vendor
    @product = product
    @version = version
    @update = update
    @edition = edition
    @language = language
    @sw_edition = sw_edition
    @target_sw = target_sw
    @target_hw = target_hw
    @other = other
  end

  def match?(other)
    CPE.match?(self, other)
  end

  def to_wfn
    attrs = %i[part vendor product version update edition language sw_edition
               target_sw target_hw other].map do |key|
      value = send(key)
      str = case value
            when nil then 'NA'
            when '*' then 'ANY'
            else "\"#{value.downcase}\""
            end
      "#{key}=#{str}"
    end
    "wfn:[#{attrs.join(',')}]"
  end

  def to_uri
    fields = [@part, @vendor, @product, @version, @update, @edition, @language]
    # Strip trailing empty fields
    fields = fields[0...-1] while fields.any? && fields[-1].nil?
    fields.map! do |f|
      f.sub('?', '%01')
       .sub('*', '%02')
    end
    'cpe:/' + fields.join(':').downcase
  end

  def to_str
    ['cpe', '2.3', @part, @vendor, @product, @version, @update, @edition,
     @language, @sw_edition, @target_sw, @target_hw, @other].join(':').downcase
  end

  class << self
    def parse(str)
      if str.start_with? 'wfn:'
        parse_wfn(str)
      elsif str.start_with? 'cpe:/'
        parse_uri(str)
      elsif str.start_with? 'cpe:2.3:'
        parse_str(str)
      else
        raise ArgumentError, 'CPE malformed'
      end
    end

    def match?(first, second)
      attr_match?(first.part, second.part) &&
        attr_match?(first.vendor, second.vendor) &&
        attr_match?(first.product, second.product) &&
        attr_match?(first.version, second.version) &&
        attr_match?(first.update, second.update) &&
        attr_match?(first.edition, second.edition) &&
        attr_match?(first.language, second.language) &&
        attr_match?(first.target_sw, second.target_sw) &&
        attr_match?(first.target_hw, second.target_hw) &&
        attr_match?(first.other, second.other)
    end

    private

    def attr_match?(first, second)
      first == '*' || second == '*' || first == second
    end

    def parse_wfn(str)
      data = {}
      WFN.parse(str)[:attr].each do |attr|
        key = attr.capture(:symbol).value.to_sym
        value = attr.capture(:value).then do |val|
          if (str = val.capture(:string))
            str.capture(:content).value
          else
            # Translate WFN special values (only applies to non-string)
            case (str = val.value)
            when 'ANY' then '*'
            when 'NA' then nil
            else str
            end
          end
        end
        if data.include? key
          raise ArgumentError, 'Attribute defined multiple times'
        end

        data[key] = value
      end

      new(**data)
    end

    def parse_uri(str)
      tag, body = str.split(':/', 2)
      raise ArgumentError, 'Not a CPE URI' if tag != 'cpe' || body.nil?

      body.sub!('%01', '?')
      body.sub!('%02', '*')

      data = {}
      data[:part], data[:vendor], data[:product], data[:version], data[:update],
        data[:edition], data[:language], remainder = body.split(':')

      raise ArgumentError, 'CPE URI malformed' unless remainder.nil?

      # All attributes are optional.
      new(**data)
    end

    # Faster implementation of CPE parser... Citrus is not fast :(
    def parse_cpe23(str)
      raise ArgumentError, 'Not a CPE str' unless str.start_with?('cpe:2.3')

      index = 7
      size = str.size
      char = str[index]
      attr = 11.times.map do
        raise ArgumentError, 'CPE formatted string malformed' if char != ':'

        index += 1
        attr_index = index
        until index >= size || (char = str[index]) == ':'
          index += 1
          index += 1 if char == '\\' # Skip escaped characters
        end
        str[attr_index...index]
      end
      raise ArgumentError, 'CPE formatted string malformed' if index != size

      attr
    end

    def parse_str(str)
      # attr = CPE23.parse(str)[:attr].map(&:value)
      attr = parse_cpe23(str)
      data = {}
      data[:part], data[:vendor], data[:product], data[:version],
        data[:update], data[:edition], data[:language], data[:sw_edition],
        data[:target_sw], data[:target_hw], data[:other], remainder = attr

      # All attributes MUST appear
      if data.any? { |_k, v| v.nil? } || !remainder.nil?
        raise ArgumentError, 'CPE formatted string malformed'
      end

      # Remove empty attributes to avoid confusing the constructor
      data.reject! { |_k, v| v.empty? }

      new(**data)
    end
  end
end
