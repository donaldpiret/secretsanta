require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  test "pick" do
    @expected.subject = 'Notifications#pick'
    @expected.body    = read_fixture('pick')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_pick(@expected.date).encoded
  end

  test "badround" do
    @expected.subject = 'Notifications#badround'
    @expected.body    = read_fixture('badround')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_badround(@expected.date).encoded
  end

end
