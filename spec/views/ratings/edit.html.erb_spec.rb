require 'spec_helper'

describe "ratings/edit" do
  before(:each) do
    @rating = assign(:rating, stub_model(Rating,
      :value => 1.5,
      :comment => "MyString"
    ))
  end

  it "renders the edit rating form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => ratings_path(@rating), :method => "post" do
      assert_select "input#rating_value", :name => "rating[value]"
      assert_select "input#rating_comment", :name => "rating[comment]"
    end
  end
end
