require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end

  test "should show stats" do
    log_in_as(@user)
    get root_path
    assert_select '#following', text: "#{@user.following.count}"
    assert_select '#followers', text: "#{@user.followers.count}"
    assert_select '#follow_form', count:0 #自分自身をフォローできない
    get user_path(User.second)
    assert_select '#follow_form', count:1 
  end
end
