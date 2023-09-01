function create_bins()
    % Author: Martin Constant (martin.constant@unige.ch)
    % Create bins.txt file if it doesn't exist
    FID = fopen('bins.txt', 'w');
    for bin = 1:12
        switch bin
            case 1
                fprintf(FID, 'bin 1\nLeft M\n.{111}{71}\n\n');
            case 2
                fprintf(FID, 'bin 2\nRight M\n.{112}{71}\n\n');
            case 3
                fprintf(FID, 'bin 3\nBoth M\n.{113}{71}\n\n');
            case 4
                fprintf(FID, 'bin 4\nLeft W\n.{121}{71}\n\n');
            case 5
                fprintf(FID, 'bin 5\nRight W\n.{122}{71}\n\n');
            case 6
                fprintf(FID, 'bin 6\nBoth W\n.{123}{71}\n\n');
            case 7
                fprintf(FID, 'bin 7\nLeft Blue\n.{211}{71}\n\n');
            case 8
                fprintf(FID, 'bin 8\nRight Blue\n.{212}{71}\n\n');
            case 9
                fprintf(FID, 'bin 9\nBoth Blue\n.{213}{71}\n\n');
            case 10
                fprintf(FID, 'bin 10\nLeft Green\n.{221}{71}\n\n');
            case 11
                fprintf(FID, 'bin 11\nRight Green\n.{222}{71}\n\n');
            case 12
                fprintf(FID, 'bin 12\nBoth Green\n.{223}{71}\n\n');
        end
    end
    fclose(FID);
end
