defmodule AshEmployeeApp.HR.Department do
  use Ash.Resource,
    domain: AshEmployeeApp.HR,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("departments")
    repo(AshEmployeeApp.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)
    end
  end

  actions do
    create :create do
      primary?(true)
      accept([:name])
    end

    defaults([:read, :update, :destroy])
  end

  relationships do
    has_many :employees, AshEmployeeApp.HR.Employee
  end

  aggregates do
    count(:employee_count, :employees)
  end
end
