defmodule AshEmployeeAppWeb.DepartmentLive.Monitor do
  use AshEmployeeAppWeb, :live_view
  alias AshEmployeeApp.HR.Department

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(5000, self(), :tick)
    end
    {:ok, load_data(socket)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, load_data(socket)}
  end

  defp load_data(socket) do
    # Load departments and include the employee_count aggregate
    departments =
      Department
      |> Ash.Query.load(:employee_count)
      |> Ash.read!()

    socket
    |> assign(:departments, departments)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <.header>
        Department Monitor
        <:subtitle>Overview of organizational departments</:subtitle>
      </.header>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-8">
        <%= for dept <- @departments do %>
          <div class="card w-full bg-base-100 shadow-xl hover:shadow-2xl transition-shadow duration-200">
            <div class="card-body">
              <h2 class="card-title text-2xl mb-2">
                {dept.name}
              </h2>

              <div class="stats stats-vertical lg:stats-horizontal shadow bg-base-200/50">
                <div class="stat place-items-center p-2">
                  <div class="stat-title text-xs uppercase tracking-wide">Employees</div>
                  <div class="stat-value text-primary text-3xl">{dept.employee_count}</div>
                </div>
              </div>

              <div class="card-actions justify-end mt-4">
                <div class="badge badge-outline">ID: {String.slice(dept.id, 0..7)}...</div>
              </div>
            </div>
          </div>
        <% end %>

        <%= if Enum.empty?(@departments) do %>
           <div class="col-span-full text-center py-12 bg-base-100 rounded-lg border-2 border-dashed border-base-300">
            <.icon name="hero-building-office-2" class="mx-auto h-12 w-12 text-base-content/30" />
            <h3 class="mt-2 text-sm font-semibold text-base-content">No departments</h3>
            <p class="mt-1 text-sm text-base-content/70">Get started by creating a new department.</p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
