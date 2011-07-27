require 'integration-specs/spec_helper'

steps "log in and switch projects", :type => :request do

  let! :project_1 do Factory(:project) end
  let! :project_2 do Factory(:project) end
  let! :user      do Factory(:user, :current_project => project_1) end

  let! :work_units_1 do
    [ Factory(:work_unit, :project => project_1, :user => user),
      Factory(:work_unit, :project => project_1, :user => user),
      Factory(:work_unit, :project => project_1, :user => user)
    ]
  end

  after do
    DatabaseCleaner.clean_with :truncation
    load 'db/seeds.rb'
  end

  it "should login as a user" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should have a work unit form (XPath Gem format)" do
    page.should have_xpath(XPath.generate do |doc|
       doc.descendant(:form)[doc.attr(:id) == "new_work_unit"][doc.attr(:action) == '/work_units']
    end)
  end

  it "should have a work unit form (Plain XPath format)" do
    page.should have_xpath("//form[@id='new_work_unit'][@action='/work_units']")
  end

  it "should have a work unit form (have_selector format)" do
    page.should have_selector("form.new_work_unit[action='/work_units']")
  end

  it "should have the name of the project" do
    p "Project 1 id in specs" => project_1.id
    p "User's current project id in specs" => user.current_project.id
    xpath = XPath.generate do |doc|
      doc.descendant(:h1)[doc.attr(:id) == 'headline'][doc.contains("#{project_1.name}")]
    end
    page.should have_xpath(xpath)
  end



end