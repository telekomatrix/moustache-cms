Feature: Admin User Management Features as user with admin role

Background: Login create default site
  Given the site "foobar" exists with the domain "example.com"
  And the user "ak730" exists with the role of "admin" in the site "foobar.example.com"
  And I authenticates as cas user "ak730"

@admin_users_index
Scenario: Admin login
  Given the user with the role exist
  | user   | role   | site               |
  | foo    | admin  | foobar.example.com |
  | bar    | editor | foobar.example.com |
  | foobar | editor | foobar.example.com |
  When I go to the admin users page 
  Then I should be on the admin users page
  And I should see "Foobar Baz" within "tr#foo"
  And I should see "foo" within "tr#foo"
  And I should see "Admin" within "tr#foo"
  And I should see "Foobar Baz" within "tr#bar"
  And I should see "bar" within "tr#bar" 
  And I should see "Editor" within "tr#bar" 
  And I should see "Foobar Baz" within "tr#foobar"
  And I should see "foobar" within "tr#foobar" 
  And I should see "Editor" within "tr#foobar" 

@create_new_user
Scenario: Create A New user
  When I go to the admin users page
  And I follow "New User" 
  Then I should be on the new admin user page 
  When I fill in "user_puid" with "foobar" 
  And I fill in "user_firstname" with "foobar"
  And I fill in "user_lastname" with "baz"
  And I fill in "user_email" with "foobar@example.com" 
  And I choose "user_role_admin" 
  And I press "Create User" 
  Then I should be on the admin users page 
  And I should see "Successfully created user profile for Foobar Baz"

@admin_edit_own_account
Scenario: Given I am logged in as an admin then I can edit my account
  When I go to the admin users page
  And I follow "ak730" within "li#ak730"
  Then I should now be editing the user "ak730"
  And I fill in "user[firstname]" with "Foobar" 
  And I fill in "user[lastname]" with "Baz" 
  And I fill in "user[email]" with "akirwan@example.com" 
  And I should not see "user[role]"
  And I press "Update User" within "div#edit_user" 
  Then I should be on the admin users page
  And I should see "Successfully updated user account for ak730"
  When I edit the account information for the user "ak730"
  And the "user[firstname]" field should contain "Foobar"
  And the "user[lastname]" field should contain "Baz"
  And the "user[email]" field should contain "akirwan@example.com" 
  
@admin_edit_user_other_user_account
Scenario: Given I am logged in as an admin then I can edit any users account
  Given the user with the role exist
  | user   | role   | site               |
  | foo    | admin  | foobar.example.com |
  | bar    | editor | foobar.example.com |
  When I go to the admin users page
  And I follow "foo" within "li#foo"
  Then I should now be editing the user "foo"
  And the "user[email]" field should contain "foo@example.com"
  And the "user_role_admin" checkbox should be checked 
  And I fill in "user[email]" with "baz@example.com" 
  Then I choose "user_role_editor" 
  And I press "Update User" within "div#edit_user" 
  Then I should be on the admin users page
  And I should see "Successfully updated user account for foo"
  When I edit the account information for the user "foo"
  Then I should now be editing the user "foo"
  And the "user[email]" field should contain "baz@example.com"
  And the "user_role_editor" checkbox should be checked
  
@admin_can_delete_own_account
Scenario: Given I am logged in as an admin then I can delete my account
  When I go to the admin users page
  And I follow "Delete" within "li#ak730"
  Then I should be on the cms html page
  
@admin_can_delete_own_account_from_page
Scenario: Given I am logged in as an admin then I can delete my account from my user page
  When I go to the admin users page
  And I follow "ak730" within "li#ak730"
  Then I should now be editing the user "ak730"
  When I follow "Delete User" within "div#delete_asset"
  Then I should be on the cms html page
  
@admin_delete_other_user_account
Scenario: Delete user account as an admin
  Given the user with the role exist
  | user   | role   | site               |
  | foobar | admin  | foobar.example.com |
  | bar    | editor | foobar.example.com |
  When I go to the admin users page
  And I follow "Delete" within "li#foobar"
  Then I should see "Successfully deleted user account for foobar"
  And I should be on the admin users page
                                                   
