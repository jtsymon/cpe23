# frozen_string_literal: true

require 'test_helper'

PERF_TEST = ENV['PERF_TEST']

class CpeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Cpe23::VERSION
  end

  def test_it_parses_empty_formatted_string
    Cpe23.parse('cpe:2.3:*:*:*:*:*:*:*:*:*:*:*')
  end

  def test_it_parses_formatted_string
    obj = Cpe23.parse('cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*')
    assert_equal obj.part, 'a'
    assert_equal obj.vendor, 'microsoft'
    assert_equal obj.product, 'internet_explorer'
    assert_equal obj.version, '8.0.6001'
    assert_equal obj.update, 'beta'
    assert_equal obj.edition, '*'
  end

  def test_it_fails_on_too_many_attributes
    assert_raises do
      Cpe23.parse('cpe:2.3:*:*:*:*:*:*:*:*:*:*:*:*')
    end
  end

  def test_it_fails_on_too_few_attributes
    assert_raises do
      Cpe23.parse('cpe:2.3:*:*:*:*:*:*:*:*:*:*')
    end
  end

  def test_it_parses_empty_uri
    Cpe23.parse('cpe:/')
  end

  def test_it_parses_uri
    obj = Cpe23.parse('cpe:/a:microsoft:internet_explorer:8.%02:sp%01')
    assert_equal obj.part, 'a'
    assert_equal obj.vendor, 'microsoft'
    assert_equal obj.product, 'internet_explorer'
    assert_equal obj.version, '8.*'
    assert_equal obj.update, 'sp?'
    assert_nil obj.edition
  end

  def test_it_parses_empty_wfn
    Cpe23.parse('wfn:[]')
  end

  def test_it_parses_wfn
    obj = Cpe23.parse('wfn:[part="a",vendor="microsoft",product="internet_explorer",version="8.0.6001",update="beta",edition=NA]')
    assert_equal obj.part, 'a'
    assert_equal obj.vendor, 'microsoft'
    assert_equal obj.product, 'internet_explorer'
    assert_equal obj.version, '8.0.6001'
    assert_equal obj.update, 'beta'
    assert_nil obj.edition
  end

  def test_wildcard_matches_everything
    wildcard = Cpe23.parse('cpe:2.3:*:*:*:*:*:*:*:*:*:*:*')
    obj = Cpe23.parse('cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*')
    assert_equal wildcard, obj
  end

  def test_everything_matches_wildcard
    wildcard = Cpe23.parse('cpe:2.3:*:*:*:*:*:*:*:*:*:*:*')
    obj = Cpe23.parse('cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*')
    assert_equal obj, wildcard
  end

  def test_to_str_roundtrip
    str = 'cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*'
    obj = Cpe23.parse(str)
    assert_equal str, obj.to_str
  end

  def test_to_uri_roundtrip
    str = 'cpe:/a:microsoft:internet_explorer:8.%02:sp%01'
    obj = Cpe23.parse(str)
    assert_equal str, obj.to_uri
  end

  def test_to_wfn_roundtrip
    # WFN encoding encodes missing attributes as NA, since we don't know whether
    # they were originally provided as NA or missing.
    # This means the test needs to expect all attributes.
    str = 'wfn:[part="a",vendor="microsoft",product="internet_explorer",version="8.0.6001",update="beta",edition=NA,language=NA,sw_edition=NA,target_sw=NA,target_hw=NA,other=NA]'
    obj = Cpe23.parse(str)
    assert_equal str, obj.to_wfn
  end

  def test_cpe23_parsing_speed
    skip unless PERF_TEST
    start = Time.now
    10_000.times do
      Cpe23.parse('cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*')
    end
    puts Time.now - start
  end

  def test_it_matches_itself
    cpe = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*'
    assert_equal cpe, cpe
  end

  def test_cpe_version_mismatch
    a = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*'
    b = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:9.0.0:beta:*:*:*:*:*:*'
    refute_equal a, b
  end

  def test_cpe_version_left_wildcard
    a = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:8.0.*:beta:*:*:*:*:*:*'
    b = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*'
    assert_equal a, b
  end

  def test_cpe_version_right_wildcard
    a = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:8.0.*:beta:*:*:*:*:*:*'
    b = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*'
    assert_equal b, a
  end

  def test_cpe_version_less_than
    a = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*'
    b = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:9.0.0:beta:*:*:*:*:*:*'
    assert_operator a, :<, b
  end

  def test_cpe_version_greater_than
    a = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*'
    b = Cpe23.parse 'cpe:2.3:a:microsoft:internet_explorer:9.0.0:beta:*:*:*:*:*:*'
    assert_operator b, :>, a
  end
end
