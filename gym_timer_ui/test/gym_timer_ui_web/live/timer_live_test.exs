defmodule GymTimerUiWeb.TimerLiveTest do
  use GymTimerUiWeb.ConnCase

  import Phoenix.LiveViewTest

  test "connected mount", %{conn: conn} do
    {:ok, view, _disconnected_html} = live(conn, "/")

    assert render(view) =~ "Clock"
  end

  test "can be paused", %{conn: conn} do
    {:ok, view, _disconnected_html} = live(conn, "/")

    assert view
           |> element("#pause")
           |> render_click()
  end
end
