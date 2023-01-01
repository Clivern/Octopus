# Copyright 2023 Clivern. All rights reserved.
# Use of this source code is governed by the MIT
# license that can be found in the LICENSE file.

defmodule BrangusWeb.ProjectController do
  @moduledoc """
  Project Controller
  """

  use BrangusWeb, :controller

  alias Brangus.Context.ProjectContext
  alias Brangus.Module.ProjectModule
  alias Brangus.Service.ValidatorService

  @default_list_limit "10"
  @default_list_offset "0"

  @doc """
  List Projects Endpoint
  """
  def list(conn, params) do
    limit = ValidatorService.get_int(params["limit"], @default_list_limit)
    offset = ValidatorService.get_int(params["offset"], @default_list_offset)

    render(conn, "list.json", %{
      projects: ProjectContext.get_projects(offset, limit),
      metadata: %{
        limit: limit,
        offset: offset,
        totalCount: ProjectContext.count_projects()
      }
    })
  end

  @doc """
  Create Project Endpoint
  """
  def create(conn, params) do
    result =
      ProjectModule.create_project(%{
        name: ValidatorService.get_str(params["name"], ""),
        description: ValidatorService.get_str(params["description"], ""),
        environment: ValidatorService.get_str(params["environment"], ""),
        username: ValidatorService.get_str(params["username"], ""),
        secret: ValidatorService.get_str(params["secret"], "")
      })

    case result do
      {:ok, project} ->
        conn
        |> put_status(:created)
        |> render("index.json", %{project: project})

      {:error, msg} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", %{error: msg})
    end
  end

  @doc """
  Index Project Endpoint
  """
  def index(conn, params) do
    result = ProjectModule.get_project(params["pid"])

    case result do
      {:not_found, msg} ->
        conn
        |> put_status(:not_found)
        |> render("error.json", %{error: msg})

      {:exist, project} ->
        conn
        |> put_status(:ok)
        |> render("index.json", %{project: project})

      {:error, msg} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", %{error: msg})
    end
  end

  @doc """
  Update Project Endpoint
  """
  def update(conn, params) do
    result =
      ProjectModule.update_project(%{
        id: ValidatorService.get_int(params["pid"], 0),
        name: ValidatorService.get_str(params["name"], ""),
        description: ValidatorService.get_str(params["description"], ""),
        environment: ValidatorService.get_str(params["environment"], ""),
        username: ValidatorService.get_str(params["username"], ""),
        secret: ValidatorService.get_str(params["secret"], "")
      })

    case result do
      {:not_found, msg} ->
        conn
        |> put_status(:not_found)
        |> render("error.json", %{error: msg})

      {:error, msg} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", %{error: msg})

      {:ok, project} ->
        conn
        |> put_status(:ok)
        |> render("index.json", %{project: project})
    end
  end

  @doc """
  Delete Project Endpoint
  """
  def delete(conn, params) do
    result = ProjectModule.delete_project(params["pid"])

    case result do
      {:not_found, msg} ->
        conn
        |> put_status(:not_found)
        |> render("error.json", %{error: msg})

      {:success, _} ->
        conn
        |> send_resp(:no_content, "")

      {:error, msg} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", %{error: msg})
    end
  end
end
