%==========================================================================
% Simplified DES Algorithm Implementation in MATLAB
%==========================================================================
% This script implements a simplified version of the Data Encryption Standard
% (DES) algorithm for educational purposes. The algorithm transforms an 
% 8-bit plaintext using an 8-bit key through a series of permutations.
%==========================================================================

%------------------------------
% Input Message and Initial Key
%------------------------------
input_message = [1 1 0 1 0 0 1 0];  % 8-bit input message (plaintext)
initial_key = [1 0 1 1 0 0 1 1];    % 8-bit initial key

%------------------------------
% Encryption Process
%------------------------------
output_message = des_algorithm(input_message, initial_key);

%---------------------------------
% Inverse Permutation (Final Step)
%---------------------------------
inverse_permutation_indices = [5 6 1 2 7 8 4 3];
encrypted_message = output_message(inverse_permutation_indices);

% Display the Final Encrypted Message
disp('Encrypted Message:');
disp(encrypted_message);

%==========================================================================
% Function Definitions
%==========================================================================

%------------------------------------------------------------------------
% des_algorithm:
%   calls initial permutation and encrypt_message function on input message.
%------------------------------------------------------------------------
function output_message = des_algorithm(input_message, initial_key)
    % Initial permutation of the input message
    initial_permuted_message = initial_permutation(input_message);

    % Split the permuted message into left and right halves
    left_half = initial_permuted_message(1:4);
    right_half = initial_permuted_message(5:8);
    total_rounds = 4;  % Total number of encryption rounds

    % Perform encryption through specified rounds
    initial_key_left_half = initial_key(1:4);
    initial_key_right_half = initial_key(5:8);
    output_message = encrypt_message(left_half, right_half, total_rounds, ...
        initial_key_left_half, initial_key_right_half);
end

%------------------------------------------------------------------------
% initial_permutation:
%   performs initial permutation of the input message.
%------------------------------------------------------------------------
function initial_permuted_message = initial_permutation(input_message)
    permuted_indices = [3 4 8 7 1 2 5 6];
    initial_permuted_message = input_message(permuted_indices);
    disp("Initial Permuted Message: ");
    disp(initial_permuted_message);
end

%------------------------------------------------------------------------
% encrypt_message:
%   executes the encryption rounds using generated round keys.
%------------------------------------------------------------------------
function output_message = encrypt_message(left_half, right_half, total_rounds, ...
                                initial_key_left_half, initial_key_right_half)
    if total_rounds == 0
        % When all rounds are complete, concatenate left and right halves
        output_message = [left_half right_half];
        return;
    end
    
    % Generate round key for the current round
    [new_key_left_half, new_key_right_half, ROUND_KEY] = generate_round_key( ...
        initial_key_left_half, initial_key_right_half, total_rounds);

    fprintf("Generated ROUND KEY for Round %d \n", 5-total_rounds);
    disp(ROUND_KEY);

    % Apply the function f to the right half and the round key
    function_f_output = f(ROUND_KEY, right_half);
    
    % XOR the left half with the function output
    new_half = xor(left_half, function_f_output);
    
    % Recursive call for the next round with swapped halves
    output_message = encrypt_message(right_half, new_half, total_rounds-1, ...
        new_key_left_half, new_key_right_half);
end

%------------------------------------------------------------------------
% generate_round_key:
%   generates round keys for each encryption round using circular shifts
%   and compression box.
%------------------------------------------------------------------------
function [left_half, right_half, ROUND_KEY] = generate_round_key(left_half, ...
                                                  right_half, total_rounds)
    % Perform circular shifts based on the current round
    if mod(total_rounds, 2) == 0
        left_half = circshift(left_half, -1);
        right_half = circshift(right_half, -1);
    else
        left_half = circshift(left_half, -2);
        right_half = circshift(right_half, -2);
    end
    
    % Combine the shifted halves
    combined_string = [left_half right_half];

    % Compression box for round key generation
    COMPRESSION_BOX = [3 1 7 4 8 6];
    ROUND_KEY = combined_string(COMPRESSION_BOX);
end

%------------------------------------------------------------------------
% f:
%   applies a sequence of operations including expansion box, XOR (.^), 
%   S-box substitution and permutation to the right half of current round 
%   message and the generated ROUND KEY.
%------------------------------------------------------------------------
function output_string = f(ROUND_KEY, right_half)
    % Expansion of the right half
    EXPANSION_BOX = [4 3 2 3 1 2];
    right_half = right_half(EXPANSION_BOX);
    
    % XOR the expanded right half with the round key
    complete_string = xor(ROUND_KEY, right_half);
    
    % Split the result for S-box substitution
    complete_string_left_half = complete_string(1:3);
    complete_string_right_half = complete_string(4:6);
    
    % Apply S-box substitutions
    s_box_one_output = s_box_one(complete_string_left_half);
    s_box_two_output = s_box_two(complete_string_right_half);

    % Combine the S-box outputs
    processed_string = [s_box_one_output s_box_two_output];

    % Apply permutation to the combined S-box output
    output_string = processed_string([4 1 3 2]);
end

%------------------------------------------------------------------------
% s_box_one:
%   perform substitution as per S-box 1, mapping 3-bit input to 2-bit
%------------------------------------------------------------------------
function two_bit_output = s_box_one(input)
    row_number = input(2);
    col_number = [input(1) input(3)];

    if row_number == 0
        if isequal(col_number, [0 0])
            two_bit_output = [0 1];
        elseif isequal(col_number, [0 1])
            two_bit_output = [0 0];
        elseif isequal(col_number, [1 0])
            two_bit_output = [0 0];
        else
            two_bit_output = [0 1];
        end
    elseif row_number == 1
        if isequal(col_number, [0 0])
            two_bit_output = [1 1];
        elseif isequal(col_number, [0 1])
            two_bit_output = [1 0];
        elseif isequal(col_number, [1 0])
            two_bit_output = [1 1];
        else
            two_bit_output = [1 0];
        end
    end
end

%------------------------------------------------------------------------
% s_box_two:
%   perform substitution as per S-box 2, mapping 3-bit input to 2-bit
%------------------------------------------------------------------------
function two_bit_output = s_box_two(input)
    row_number = input(2);
    col_number = [input(1) input(3)];

    if row_number == 0
        if isequal(col_number, [0 0])
            two_bit_output = [1 1];
        elseif isequal(col_number, [0 1])
            two_bit_output = [1 0];
        elseif isequal(col_number, [1 0])
            two_bit_output = [1 0];
        else
            two_bit_output = [0 1];
        end
    elseif row_number == 1
        if isequal(col_number, [0 0])
            two_bit_output = [0 0];
        elseif isequal(col_number, [0 1])
            two_bit_output = [1 0];
        elseif isequal(col_number, [1 0])
            two_bit_output = [1 0];
        else
            two_bit_output = [0 1];
        end
    end
end

%==========================================================================