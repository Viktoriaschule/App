package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/nealwon/go-flutter-plugin-sqlite"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(800, 600),
	flutter.AddPlugin(sqflite.NewSqflitePlugin(flutter.ProjectOrganizationName, flutter.ProjectName)),
}
