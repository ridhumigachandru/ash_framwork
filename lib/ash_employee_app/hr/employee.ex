defmodule AshEmployeeApp.HR.Employee do
  use Ash.Resource,
    domain: AshEmployeeApp.HR,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "employees"
    repo AshEmployeeApp.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :age, :integer do
      allow_nil? false
    end

    attribute :salary, :integer do
      allow_nil? false
    end
  end

  actions do
  create :create do
    primary? true
    accept [:name, :age, :salary, :department_id]
  end

  defaults [:read, :update, :destroy]
end


  relationships do
    belongs_to :department, AshEmployeeApp.HR.Department do
      allow_nil? false
    end
  end

  validations do
    validate match(:name, ~r/^[A-Za-z\s]+$/) do
      message "name must contain only letters"
    end

    validate compare(:age, greater_than_or_equal_to: 18, less_than_or_equal_to: 60)

    validate compare(:salary, greater_than: 0)
  end

  calculations do
    calculate :annual_salary, :integer, expr(salary * 12)
  end

  # ✅ Policies (Authorization)

end
