function C = Row_Wise_Conv(A, B)

    % Finding the size of the first matrix
    [rowsA, colsA] = size(A);

    % Finding the size of the second matrix
    [rowsB, colsB] = size(B);

    % Checking the equality of number of rows
    if rowsA ~= rowsB
        disp("The number of rows of each matrix must be equal!")
        C = nan;
        return
    end

    % Final length of the convolution
    conv_length = colsA + colsB - 1;

    % Column's and row's indices for toeplitz matrix
    col_idx = [A, zeros(rowsA, colsB-1)];
    row_idx = [A(1,1), zeros(1, colsB-1)];

    % Defining the toeplitz matrix
    T = toeplitz(col_idx', row_idx');
   
    % Resahpeing the toeplitz matrix it to a 3d matrix, where ith page of it is the shifted versions of ith row of the first matrix
    T = reshape(T', [colsB, conv_length, rowsA]);

    % Reshaping the second matrix to 3d matrix, where ith page of it is the ith row of the second matrix
    B_reshaped = permute(reshape(B, [rowsA, 1, colsB]), [2,3,1]);

    % Calculating the convolution using the shifted rows of first matrix and exact rows of the second one
    C = reshape(pagemtimes(B_reshaped, T), [conv_length, rowsA])';
end
