# frozen_string_literal: true

require 'test_helper'

class CpeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Cpe::VERSION
  end

  def test_it_parses_formatted_string
    obj = CPE.parse('cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*')
    assert_equal obj.part, 'a'
    assert_equal obj.vendor, 'microsoft'
    assert_equal obj.product, 'internet_explorer'
    assert_equal obj.version, '8.0.6001'
    assert_equal obj.update, 'beta'
    assert_equal obj.edition, '*'
  end

  def test_it_fails_on_too_many_attributes
    assert_raises(ArgumentError) do
      CPE.parse('cpe:2.3:*:*:*:*:*:*:*:*:*:*:*:*')
    end
  end

  def test_it_fails_on_too_few_attributes
    assert_raises(ArgumentError) do
      CPE.parse('cpe:2.3:*:*:*:*:*:*:*:*:*:*')
    end
  end

  def test_it_parses_empty_uri
    CPE.parse('cpe:/')
  end

  def test_it_parses_empty_wfn
    CPE.parse('wfn:[]')
  end

  def test_it_parses_wfn
    obj = CPE.parse('wfn:[part="a",vendor="microsoft",product="internet_explorer",version="8.0.6001",update="beta",edition=NA]')
    assert_equal obj.part, 'a'
    assert_equal obj.vendor, 'microsoft'
    assert_equal obj.product, 'internet_explorer'
    assert_equal obj.version, '8.0.6001'
    assert_equal obj.update, 'beta'
    assert_nil obj.edition
  end
end
