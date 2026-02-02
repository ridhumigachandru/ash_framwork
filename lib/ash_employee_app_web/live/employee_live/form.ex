defmodule AshEmployeeAppWeb.EmployeeLive.Form do
  use AshEmployeeAppWeb, :live_view

  alias AshEmployeeApp.HR
  alias AshEmployeeApp.HR.Employee

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage employee records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="employee-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:age]} type="number" label="Age" />
        <.input field={@form[:salary]} type="number" label="Salary" />
        <.input field={@form[:department_id]} type="text" label="Department" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Employee</.button>
          <.button navigate={return_path(@return_to, @employee)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    employee = HR.get_employee!(id)

    socket
    |> assign(:page_title, "Edit Employee")
    |> assign(:employee, employee)
    |> assign(:form, to_form(HR.change_employee(employee)))
  end

  defp apply_action(socket, :new, _params) do
    employee = %Employee{}

    socket
    |> assign(:page_title, "New Employee")
    |> assign(:employee, employee)
    |> assign(:form, to_form(HR.change_employee(employee)))
  end

  @impl true
  def handle_event("validate", %{"employee" => employee_params}, socket) do
    changeset = HR.change_employee(socket.assigns.employee, employee_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"employee" => employee_params}, socket) do
    save_employee(socket, socket.assigns.live_action, employee_params)
  end

  defp save_employee(socket, :edit, employee_params) do
    case HR.update_employee(socket.assigns.employee, employee_params) do
      {:ok, employee} ->
        {:noreply,
         socket
         |> put_flash(:info, "Employee updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, employee))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_employee(socket, :new, employee_params) do
    case HR.create_employee(employee_params) do
      {:ok, employee} ->
        {:noreply,
         socket
         |> put_flash(:info, "Employee created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, employee))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _employee), do: ~p"/employees"
  defp return_path("show", employee), do: ~p"/employees/#{employee}"
end
