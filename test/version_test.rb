# frozen_string_literal: true

require 'test_helper'

class VersionTest < Minitest::Test
  def test_it_matches_itself
    ver = Cpe23::Version.new('1.0.1')
    assert_equal ver, ver
  end

  def test_it_matches_left_wildcard
    assert_equal Cpe23::Version.new('1.*'), Cpe23::Version.new('1.1.2.3')
  end

  def test_it_matches_right_wildcard
    assert_equal Cpe23::Version.new('1.1.2.3'), Cpe23::Version.new('1.*')
  end

  def test_it_mismatches_different_version
    refute_equal Cpe23::Version.new('1.0'), Cpe23::Version.new('2.0')
  end

  def test_it_mismatches_different_left_wildcard
    refute_equal Cpe23::Version.new('1.*'), Cpe23::Version.new('2.0')
  end

  def test_it_mismatches_different_right_wildcard
    refute_equal Cpe23::Version.new('2.0'), Cpe23::Version.new('1.*')
  end

  def test_less_than
    assert_operator Cpe23::Version.new('1.0'), :<, Cpe23::Version.new('2.0')
  end

  def test_greater_than
    assert_operator Cpe23::Version.new('2.0'), :>, Cpe23::Version.new('1.0')
  end

  def test_less_than_wildcard
    assert_operator Cpe23::Version.new('1.*'), :<, Cpe23::Version.new('2.*')
  end

  def test_greater_than_wildcard
    assert_operator Cpe23::Version.new('2.*'), :>, Cpe23::Version.new('1.*')
  end
end
