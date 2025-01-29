package main

import (
	"flag"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"html/template"
	"net/http"
)

func main() {
	devFlag := flag.Bool("dev", false, "Run in development mode")
	flag.Parse()

	e := echo.New()

	e.Use(middleware.Logger())

	indexContent := template.Must(template.ParseFiles("index.gohtml"))

	e.File("/banner.jpg", "banner.jpg")

	e.GET("/", func(c echo.Context) error {
		return indexContent.Execute(c.Response().Writer, "home")
	})

	e.GET("/home", func(c echo.Context) error {
		if c.Request().Header.Get("HX-Request") == "" {
			return indexContent.Execute(c.Response().Writer, "home")
		}
		return c.String(http.StatusOK, "Home")
	})

	e.GET("/projects", func(c echo.Context) error {
		if c.Request().Header.Get("HX-Request") == "" {
			return indexContent.Execute(c.Response().Writer, "projects")
		}
		return c.String(http.StatusOK, "Projects")
	})

	if devFlag != nil && *devFlag {
		e.Logger.Fatal(e.Start(":8080"))
	}

	e.Logger.Fatal(e.Start(":80"))
}
