defmodule AshEmployeeApp.Repo do
  use AshPostgres.Repo,
    otp_app: :ash_employee_app

  def installed_extensions do
    ["uuid-ossp", "pgcrypto"]
  end
end
