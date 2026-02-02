defmodule AshEmployeeApp.HR do
  use Ash.Domain

  resources do
    resource(AshEmployeeApp.HR.Employee)
    resource(AshEmployeeApp.HR.Department)
  end
end
