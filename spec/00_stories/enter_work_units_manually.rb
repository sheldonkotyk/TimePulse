require 'spec_helper'

steps "User manually enters work units", :type => :request do

  let! :client do Factory(:client, :name => 'Foo, Inc.') end
  let! :project do Factory(:project, :client => client) end
  let! :user      do Factory(:user, :current_project => project) end

  before do
    @work_unit_count = WorkUnit.count
  end

  it "should login as a user" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should have the name of the project" do
    page.should have_xpath(make_xpath(project.name){|name|
      descendant(:h1).all(attr(:id) == 'headline', content(name))
    })
  end

  it "when I fill in valid work unit information" do
    fill_in "Start time", :with => Time.now - 1.hour
    fill_in "Stop time", :with => Time.now
    fill_in "Notes", :with => "An hour of work"
    click_button "Save Changes"    
  end

  it "should add a work unit to the database" do
    WorkUnit.count.should == @work_unit_count + 1
    @workUnit
  end

  it "should have the correct values for the work unit" do
    @work_unit = WorkUnit.last
    @work_unit.hours.should == 1.00
    @work_unit.notes.should == "An hour of work"   
  end

  it "should show the work unit in recent work" do
    within "#recent_work" do
      page.should have_content("1.00")
      page.should have_link("Edit", "/work_units/#{@work_unit.id}/edit")
    end 
  end

  it "should show the work unit in current project report" do
    within "#current_project" do
      page.should have_content("An hour of work")
    end
  end

end
