defmodule AshEmployeeAppWeb.EmployeeLive.Monitor do
  use AshEmployeeAppWeb, :live_view
  alias AshEmployeeApp.HR.Employee

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Refresh every 5 seconds
      :timer.send_interval(5000, self(), :tick)
    end

    {:ok, load_data(socket)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, load_data(socket)}
  end

  defp load_data(socket) do
    employees = Ash.read!(Employee, actor: nil)
    count = length(employees)
    # Calculate average salary safely
    avg_salary =
      if count > 0 do
        Enum.reduce(employees, 0, fn e, acc -> acc + e.salary end) / count
      else
        0
      end

    socket
    |> assign(:employees, employees)
    |> assign(:stats, %{
      total: count,
      avg_salary: avg_salary
    })
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <.header>
        Employee Monitor
        <:subtitle>Real-time overview of employee workforce</:subtitle>
      </.header>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <div class="stat bg-base-100 shadow rounded-lg p-4">
          <div class="stat-figure text-primary">
            <.icon name="hero-users" class="w-8 h-8" />
          </div>
          <div class="stat-title">Total Employees</div>
          <div class="stat-value text-primary">{@stats.total}</div>
          <div class="stat-desc">Current active workforce</div>
        </div>

        <div class="stat bg-base-100 shadow rounded-lg p-4">
          <div class="stat-figure text-secondary">
            <.icon name="hero-currency-dollar" class="w-8 h-8" />
          </div>
          <div class="stat-title">Average Salary</div>
          <div class="stat-value text-secondary">
            {Number.Currency.number_to_currency(@stats.avg_salary)}
          </div>
          <div class="stat-desc">Monthly average</div>
        </div>
      </div>

      <!-- Employee Table -->
      <div class="bg-base-100 rounded-lg shadow overflow-hidden">
        <.table id="employees" rows={@employees}>
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
            <span class="badge badge-ghost">{employee.department_id}</span>
          </:col>
        </.table>
      </div>
    </div>
    """
  end
end
