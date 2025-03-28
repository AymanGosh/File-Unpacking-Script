#!/bin/bash

# Function to set up the test environment
setup_test_environment() {
    echo "Setting up test environment..."

    # Define test directory
    TEST_DIR="test_env"
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR/nested/dir1"
    mkdir -p "$TEST_DIR/nested/dir2"

    # Create test files
    echo "Hello, World!" > "$TEST_DIR/nested/dir1/file1.txt"
    echo "Another file" > "$TEST_DIR/nested/dir2/file2.txt"

    # Create first-level archives
    tar -czf "$TEST_DIR/dir1.tar.gz" -C "$TEST_DIR/nested" dir1
    tar -cjf "$TEST_DIR/dir2.tar.bz2" -C "$TEST_DIR/nested" dir2
    zip -r "$TEST_DIR/dir1.zip" "$TEST_DIR/nested/dir1" > /dev/null

    # Create second-level nested archives
    mkdir -p "$TEST_DIR/archives"
    tar -czf "$TEST_DIR/archives/nested_arch.tar.gz" -C "$TEST_DIR" dir1.tar.gz dir2.tar.bz2 dir1.zip

    echo "Test environment setup complete."
}

# Function to run the DFS script
run_script() {
    echo "Running DFS script..."
    bash dfs_script.sh > output.log 2>&1
    echo "DFS script execution completed."
}

# Function to validate results
validate_results() {
    echo "Validating results..."

    # Check if first-level archives were extracted
    if [ -d "test_env/nested/dir1" ] && [ -d "test_env/nested/dir2" ]; then
        echo "✔ First-level directories extracted successfully."
    else
        echo "❌ First-level directory extraction failed."
    fi

    # Check if files exist after extraction
    if [ -f "test_env/nested/dir1/file1.txt" ] && [ -f "test_env/nested/dir2/file2.txt" ]; then
        echo "✔ Files extracted successfully."
    else
        echo "❌ File extraction failed."
    fi

    # Check if the nested archive was handled
    if [ -d "test_env/archives" ] && [ -f "test_env/archives/nested_arch.tar.gz" ]; then
        echo "✔ Nested archive exists."
    else
        echo "❌ Nested archive missing."
    fi

    # Check if nested archives were extracted
    if [ -f "test_env/dir1.tar.gz" ] && [ -f "test_env/dir2.tar.bz2" ] && [ -f "test_env/dir1.zip" ]; then
        echo "✔ Nested archives extracted correctly."
    else
        echo "❌ Nested archive extraction failed."
    fi

    # Check script output for directory traversal
    grep -q "Entering extracted directory" output.log && echo "✔ DFS function worked correctly." || echo "❌ DFS function did not work correctly."
}

# Function to clean up after the test
cleanup() {
    echo "Cleaning up test files..."
    rm -rf test_env output.log
    echo "Cleanup complete."
}

# Main function to execute tests
main() {
    setup_test_environment
    run_script
    validate_results
    cleanup
}

# Run tests
main
