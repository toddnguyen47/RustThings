---
title: Rust Ownership
header-includes:
  <link href="https://fonts.googleapis.com/css?family=Lato&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css?family=Share+Tech+Mono&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="RustOwnership.css" />
---

## Ownership Introduction

- Ownership is Rust's most unique feature
- Enables Rust to make memory safety guarantees **WITHOUT** needing a garbage collector
- Related features to Ownership:
  - Borrowing
  - Slices
  - How Rust lays data out in memory

## What is Ownership?

- All programs have to manage the way they use a computer's memory
- In other languages, two popular methods of managing memory are:
  1. Automatic garbage collection, e.g. Java
  2. Programmer explicitly allocate and free memory, e.g. C
