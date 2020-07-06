---
title: Rust Ownership
header-includes:
  <link href="https://fonts.googleapis.com/css?family=Lato&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css?family=Share+Tech+Mono&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Oxygen&display=swap" rel="stylesheet"> 
---

## Ownership Introduction

- Ownership is Rust's most unique feature
- Enables Rust to make memory safety guarantees **WITHOUT** needing a garbage collector
- Related features to Ownership:
  - Borrowing
  - Slices
  - How Rust lays data out in memory

---

## What is Ownership?

- All programs have to manage the way they use a computer's memory
- In other languages, two popular methods of managing memory are:
  1. Automatic garbage collection, e.g. Java
  2. Programmer explicitly allocate and free memory, e.g. C
- Rust uses a 3rd approach: memory is managed through a system of ownership with a set of rules that the **compiler** checks at **compile time**
  - Rust code is first compiled then ran.
  - If we can check memory management at compile time, we will not run into memory problems come runtime!

---

## Stack vs. Heap

<img src="images/stackOfPlates.jpeg" alt="Stack of Plates" height="300px" />

| Information          | Stack                                | Heap                                                                                                          |
| -------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| Data Stored          | Fixed Size                           | Unknown size                                                                                                  |
| Storage Organization | Organized. Last In, First Out (LIFO) | Unorganized. The operating system finds a heap size that is large enough, allocates it, then return a pointer |

Heap Example: Think of being seated at a restaurant. When you enter, you state the number of people in your group, and the staff finds an empty table that fits everyone and leads you there. If someone in your group comes late, they can ask where you’ve been seated to find you.

So _what exactly does Ownership addresses?_

- Keeping track of what parts of code are using what data on the heap
- Minimizing the amount of duplicate data on the heap
- Cleaning up unused data on the heap so you don’t run out of space

---

## Ownership Rules

Three important rules of ownership:

1. Each value in Rust has a variable that’s called its **owner**.
1. There can only be **one owner** at a time.
1. When the **owner** goes out of scope, the value will be dropped.

### Scope?

- A scope is the range within a program for which an item is valid.

```rust
{                      // s is not valid here, it’s not yet declared
    let s = "hello";   // s is valid from this point forward

    // do stuff with s
}                      // this scope is now over, and s is no longer valid
```

- When `s` comes into scope, it is valid.
- It remains valid until it goes out of scope.

### Memory and Allocation

- Note that memory allocation/drop is only done with complex types! Simple types such as `int` and `float` do not need memory allocation as they have a known, fixed size that can be stored on the stack.
- A `String` holds a variable number of characters that make up a word.
- With the `String` type, in order to support a **mutable, growable** piece of text, we need to allocate an amount of memory on the **heap**, unknown at compile time, to hold the contents. This means:
  - The memory must be requested from the operating system at runtime.
  - We need a way of returning this memory to the operating system when we’re done with our `String`.
- First part (Allocation) is done here:

```rust
let mut s = String::from("hello");
```

- Second part (freeing memory) is the hard part.
- Historically in C/C++, we need to pair exactly one allocate with exactly one free
  - C: The infamous `malloc` and `free`
  - C++: `new` and `delete`
- Rust takes a different path: the memory is automatically returned once the variable that owns it goes out of scope.

```rust
{
    let s = String::from("hello"); // s is valid from this point forward

    // do stuff with s
}                                  // this scope is now over, and s is no
                                   // longer valid. drop() is called here!
```

When a variable goes out of scope, Rust calls a special function for us. This function is called `drop`, and it’s where the author of `String` can put the code to return the memory. Rust calls `drop` **automatically** at the closing curly bracket.

### Sample String Memory Allocation

Consider this piece of code.

```rust
let s1 = String::from("hello");
let s2 = s1;
```

This is a visual representation of what is happening in other languages such as C++.

<img src="images/heapAllocation.svg" alt="heapRepresentation" width="300px" />

- Both pointers are pointing to the same location. This is a problem: when `s2` and `s1` go out of scope, they will both try to free the same memory. This is known as a **double free error** and is one of the memory safety bugs we mentioned previously.
- Freeing memory twice can lead to **memory corruption**, which can potentially lead to security vulnerabilities
- To ensure memory safety, there’s one more detail to what happens in this situation in Rust. Instead of trying to copy the allocated memory, Rust considers `s1` to **no longer be valid** and, therefore, Rust doesn’t need to free anything when s1 goes out of scope.
- This code will produce an error!

```rust
let s1 = String::from("hello");
let s2 = s1;

println!("{}, world!", s1);
```

Output:

```
error[E0382]: use of moved value: `s1`
 --> src/main.rs:5:28
  |
3 |     let s2 = s1;
  |         -- value moved here
4 |
5 |     println!("{}, world!", s1);
  |                            ^^ value used here after move
  |
```

- You might notice the **moved** keyword. What is a **move**?
- A **move** is Rust's concept of a somewhat similar concept, which is making a **shallow copy**. But in Rust, after making a **shallow copy**, Rust also invalidates the first variable. This is known as a **move**.
  - Think of it as the first variable's data got **MOVED** to the second variable.
- This is a visual representation of what is happening in Rust.

<img src="images/heapAllocation2.svg" alt="heapRepresentation2" width="300px" />

- So what does this solve? It solves our **double free error** problem!
- With only `s2` valid, when it goes out of scope, it **alone** will free the memory, and we’re done.

---

## More Information - Ownership and Functions

- Phew, that was a lot of coding jargon!
- If you are interested in how Ownership and functions work, please let me know!
- Here's some code as to how Ownership work with functions.

```rust
fn main() {
    let s = String::from("hello");  // s comes into scope

    takes_ownership(s);             // s's value moves into the function...
                                    // ... and so is no longer valid here

    let x = 5;                      // x comes into scope

    makes_copy(x);                  // x would move into the function,
                                    // but i32 is Copy, so it’s okay to still
                                    // use x afterward

} // Here, x goes out of scope, then s. But because s's value was moved, nothing
  // special happens.

fn takes_ownership(some_string: String) { // some_string comes into scope
    println!("{}", some_string);
} // Here, some_string goes out of scope and `drop` is called. The backing
  // memory is freed.

fn makes_copy(some_integer: i32) { // some_integer comes into scope
    println!("{}", some_integer);
} // Here, some_integer goes out of scope. Nothing special happens.
```

- If we tried to use `s` after the call to `takes_ownership`, Rust would throw a compile-time error. These static checks protect us from mistakes.

## More Information - Ownership and Return Variables

- Returning values can also transfer ownership

```rust
fn main() {
    let s1 = gives_ownership();         // gives_ownership moves its return
                                        // value into s1

    let s2 = String::from("hello");     // s2 comes into scope

    let s3 = takes_and_gives_back(s2);  // s2 is moved into
                                        // takes_and_gives_back, which also
                                        // moves its return value into s3
} // Here, s3 goes out of scope and is dropped. s2 goes out of scope but was
  // moved, so nothing happens. s1 goes out of scope and is dropped.

fn gives_ownership() -> String {             // gives_ownership will move its
                                             // return value into the function
                                             // that calls it

    let some_string = String::from("hello"); // some_string comes into scope

    some_string                              // some_string is returned and
                                             // moves out to the calling
                                             // function
}

// takes_and_gives_back will take a String and return one
fn takes_and_gives_back(a_string: String) -> String { // a_string comes into
                                                      // scope

    a_string  // a_string is returned and moves out to the calling function
}
```

- As you might notice, the ownership of a variable follows the same pattern every time: _assigning a value to another variable moves it_.
- When a variable that includes data on the heap goes out of scope, the value will be cleaned up by drop unless the data has been moved to be owned by another variable.

## References and Borrowing

- More information can be found [here](https://doc.rust-lang.org/stable/book/ch04-02-references-and-borrowing.html).
