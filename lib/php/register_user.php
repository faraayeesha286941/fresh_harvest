<?php
require 'db_connect.php'; // Ensure you have a db_connect.php file to handle the database connection

header('Content-Type: application/json'); // Set header to return JSON content

// Extract user data from POST request
$first_name = mysqli_real_escape_string($conn, $_POST['first_name']);
$last_name = mysqli_real_escape_string($conn, $_POST['last_name']);
$username = mysqli_real_escape_string($conn, $_POST['username']);
$email = mysqli_real_escape_string($conn, $_POST['email']);
$password = mysqli_real_escape_string($conn, $_POST['password']);

// Hash the password for security
$password_hashed = password_hash($password, PASSWORD_DEFAULT);

// Prepare SQL statement to insert the new user into the database
$sql = "INSERT INTO db_user (first_name, last_name, username, email, password) VALUES ('$first_name', '$last_name', '$username', '$email', '$password_hashed')";

// Execute the query and check if it's successful
if(mysqli_query($conn, $sql)){
    echo json_encode(["message" => "User registered successfully"]);
} else {
    echo json_encode(["message" => "Error registering user"]);
}

mysqli_close($conn); // Close database connection
?>
