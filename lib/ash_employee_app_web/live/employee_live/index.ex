defmodule AshEmployeeAppWeb.EmployeeLive.Index do
  use AshEmployeeAppWeb, :live_view

  require Ash.Query
  import Ash.Expr

  alias AshEmployeeApp.HR.Employee
  alias AshEmployeeApp.HR.Department

  @impl true
  def mount(_params, _session, socket) do
    employees = Ash.read!(Employee)
    departments = Ash.read!(Department)

    {:ok,
     socket
     |> assign(:employees, employees)
     |> assign(:departments, departments)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    emp =
      Employee
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(expr(id == ^id))
      |> Ash.read_one!()

    Ash.destroy!(emp)

    {:noreply, assign(socket, :employees, Ash.read!(Employee))}
  end
end
