require 'rails_helper'

RSpec.describe "toppings/new", type: :view do
  before(:each) do
    assign(:topping, Topping.new(
      name: "MyString",
      dessert: nil
    ))
  end

  it "renders new topping form" do
    render

    assert_select "form[action=?][method=?]", toppings_path, "post" do

      assert_select "input[name=?]", "topping[name]"

      assert_select "input[name=?]", "topping[dessert_id]"
    end
  end
end
