<?php
require 'db_connect.php'; // Ensure you have a db_connect.php file to handle the database connection

header('Content-Type: application/json'); // Set header to return JSON content

// Extract login credentials from POST request
$login = mysqli_real_escape_string($conn, $_POST['login']); // Login can be either email or username
$password = mysqli_real_escape_string($conn, $_POST['password']);

// Prepare SQL statement to find the user either by email or username
$sql = "SELECT * FROM db_user WHERE email = '$login' OR username = '$login'";

$result = mysqli_query($conn, $sql);
$user = mysqli_fetch_assoc($result);

if ($user) {
    // Verify the password
    if (password_verify($password, $user['password'])) {
        echo json_encode(["message" => "Login successful"]);
    } else {
        echo json_encode(["message" => "Invalid login credentials"]);
    }
} else {
    echo json_encode(["message" => "User not found"]);
}

mysqli_close($conn); // Close database connection
?>
