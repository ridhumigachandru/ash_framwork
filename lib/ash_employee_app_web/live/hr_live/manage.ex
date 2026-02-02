defmodule AshEmployeeAppWeb.HRLive.Manage do
  use AshEmployeeAppWeb, :live_view
  alias AshEmployeeApp.HR.{Employee, Department}
  alias AshPhoenix.Form

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:active_tab, :employees)
      |> assign(:live_action, :index)
      |> assign(:form, nil)
      |> assign(:trigger_submit, false)
      |> load_data()

    {:ok, socket}
  end

  defp load_data(socket) do
    # Load all data for listing on mount. In a real app we might paginate.
    socket
    |> assign(:employees, Ash.read!(Employee))
    |> assign(:departments, Ash.read!(Department))
    |> assign(:department_options, department_options())
  end

  defp department_options do
    Department
    |> Ash.read!()
    |> Enum.map(&{&1.name, &1.id})
  end

  @impl true
  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, String.to_existing_atom(tab))}
  end

  # --- DELETE ---
  def handle_event("delete_employee", %{"id" => id}, socket) do
    Employee
    |> Ash.get!(id)
    |> Ash.destroy!()

    {:noreply, load_data(socket)}
  end

  def handle_event("delete_department", %{"id" => id}, socket) do
    Department
    |> Ash.get!(id)
    |> Ash.destroy!()

    {:noreply, load_data(socket)}
  end

  # --- EDIT / NEW ---
  def handle_event("new_employee", _params, socket) do
    form =
      Employee
      |> Form.for_create(:create, api: AshEmployeeApp.HR)
      |> to_form()

    {:noreply,
     socket
     |> assign(:live_action, :new_employee)
     |> assign(:form, form)}
  end

  def handle_event("edit_employee", %{"id" => id}, socket) do
    employee = Ash.get!(Employee, id)

    form =
      employee
      |> Form.for_update(:update, api: AshEmployeeApp.HR)
      |> to_form()

    {:noreply,
     socket
     |> assign(:live_action, :edit_employee)
     |> assign(:form, form)}
  end

  def handle_event("new_department", _params, socket) do
    form =
      Department
      |> Form.for_create(:create, api: AshEmployeeApp.HR)
      |> to_form()

    {:noreply,
     socket
     |> assign(:live_action, :new_department)
     |> assign(:form, form)}
  end

  def handle_event("edit_department", %{"id" => id}, socket) do
    department = Ash.get!(Department, id)

    form =
      department
      |> Form.for_update(:update, api: AshEmployeeApp.HR)
      |> to_form()

    {:noreply,
     socket
     |> assign(:live_action, :edit_department)
     |> assign(:form, form)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :live_action, :index)}
  end

  # --- FORM SUBMISSION ---
  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"form" => params}, socket) do
    case Form.submit(socket.assigns.form, params: params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Saved successfully")
         |> assign(:live_action, :index)
         |> load_data()}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <.header>
        HR Management
        <:subtitle>Manage employees and department records</:subtitle>
      </.header>

      <!-- Tabs -->
      <div role="tablist" class="tabs tabs-boxed mb-6 bg-base-200 p-1 rounded-lg inline-flex">
        <a role="tab" class={["tab", @active_tab == :employees && "tab-active bg-primary text-primary-content"]}
           phx-click="change_tab" phx-value-tab="employees">Employees</a>
        <a role="tab" class={["tab", @active_tab == :departments && "tab-active bg-primary text-primary-content"]}
           phx-click="change_tab" phx-value-tab="departments">Departments</a>
      </div>

      <!-- Content -->
      <div :if={@active_tab == :employees}>
        <div class="flex justify-end mb-4">
          <.button phx-click="new_employee" class="gap-2">
            <.icon name="hero-plus" />
            Add Employee
          </.button>
        </div>

        <div class="bg-base-100 rounded-lg shadow overflow-hidden">
        <.table id="employees-manage" rows={@employees}>
          <:col :let={employee} label="Name">
            <div class="font-bold">{employee.name}</div>
          </:col>
          <:col :let={employee} label="Age">
            {employee.age}
          </:col>
          <:col :let={employee} label="Salary">
            {Number.Currency.number_to_currency(employee.salary)}
          </:col>
          <:col :let={employee} label="Department ID">
            <span class="badge badge-ghost text-xs">{employee.department_id}</span>
          </:col>
          <:action :let={employee}>
            <div class="flex gap-2">
              <button phx-click="edit_employee" phx-value-id={employee.id} class="btn btn-ghost btn-xs">
                <.icon name="hero-pencil" class="w-4 h-4" />
              </button>
              <button phx-click="delete_employee" phx-value-id={employee.id} data-confirm="Are you sure?" class="btn btn-ghost btn-xs text-error">
                <.icon name="hero-trash" class="w-4 h-4" />
              </button>
            </div>
          </:action>
        </.table>
        </div>
      </div>

      <div :if={@active_tab == :departments}>
        <div class="flex justify-end mb-4">
          <.button phx-click="new_department" class="gap-2">
            <.icon name="hero-plus" />
            Add Department
          </.button>
        </div>

        <div class="bg-base-100 rounded-lg shadow overflow-hidden">
        <.table id="departments-manage" rows={@departments}>
          <:col :let={item} label="Name">
            <span class="font-bold text-lg">{item.name}</span>
          </:col>
          <:col :let={item} label="ID">
            <span class="font-mono text-xs opacity-50">{item.id}</span>
          </:col>
          <:action :let={item}>
            <div class="flex gap-2">
              <button phx-click="edit_department" phx-value-id={item.id} class="btn btn-sm btn-ghost">
                <.icon name="hero-pencil" class="w-4 h-4" />
              </button>
              <button phx-click="delete_department" phx-value-id={item.id} data-confirm="Are you sure?" class="btn btn-sm btn-ghost text-error">
                <.icon name="hero-trash" class="w-4 h-4" />
              </button>
            </div>
          </:action>
        </.table>
        </div>
      </div>

      <!-- Modals -->
      <.modal :if={@live_action in [:new_employee, :edit_employee]} id="employee-modal" show on_cancel={JS.push("close_modal")}>
        <.header>
          {if @live_action == :new_employee, do: "New Employee", else: "Edit Employee"}
        </.header>
        <.simple_form for={@form} phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} label="Name" placeholder="John Doe" />
          <.input field={@form[:age]} type="number" label="Age" />
          <.input field={@form[:salary]} type="number" label="Salary" />
          <.input field={@form[:department_id]} type="select" options={@department_options} label="Department" />
          <:actions>
            <.button class="w-full">Save Employee</.button>
          </:actions>
        </.simple_form>
      </.modal>

      <.modal :if={@live_action in [:new_department, :edit_department]} id="department-modal" show on_cancel={JS.push("close_modal")}>
        <.header>
          {if @live_action == :new_department, do: "New Department", else: "Edit Department"}
        </.header>
        <.simple_form for={@form} phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} label="Name" placeholder="Engineering" />
          <:actions>
            <.button class="w-full">Save Department</.button>
          </:actions>
        </.simple_form>
      </.modal>
    </div>
    """
  end
end
