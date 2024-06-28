# Gym Management Flutter Project

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## DEV Commands
### Code Generation

In this project, we use the build_runner package to generate code for various tasks such as JSON serialization, Hive type adapters, and more. This helps maintain a clean and efficient codebase.

To generate the necessary files, run the following command:
```
dart run build_runner build
```
This command will scan the project for files annotated for code generation and create the corresponding output files. Running this command is essential after making changes to any files that require code generation.