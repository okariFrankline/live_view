defmodule LearnWeb.Router do
  use LearnWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LearnWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LearnWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/", LearnWeb do
    pipe_through :browser

    live "/guess", GuessLive.Index, :new
    live "/guess/retry", GuessLive.Index, :retry
    live "/guess/correct", GuessLive.Index, :correct
    live "/guess/over", GuessLive.Index, :game_over
  end

  # Other scopes may use custom stacks.
  # scope "/api", LearnWeb do
  #   pipe_through :api
  # end
end
