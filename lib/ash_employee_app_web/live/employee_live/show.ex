defmodule AshEmployeeAppWeb.EmployeeLive.Show do
  use AshEmployeeAppWeb, :live_view

  alias AshEmployeeApp.HR

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Employee {@employee.id}
        <:subtitle>This is a employee record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/employees"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/employees/#{@employee}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit employee
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@employee.name}</:item>
        <:item title="Age">{@employee.age}</:item>
        <:item title="Salary">{@employee.salary}</:item>
        <:item title="Department">{@employee.department_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Employee")
     |> assign(:employee, HR.get_employee!(id))}
  end
end
