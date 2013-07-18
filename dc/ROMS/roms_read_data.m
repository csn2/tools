function [out] = roms_read_data(folder,varname)
    
    % get all history files
    if isdir(folder)
        files = roms_find_file(folder,'his');
    else
        files = folder;
    end
        
    k = 1;
    
    for ii=1:size(files,1)
        if isdir(folder)
            fname = [folder '\' files(ii,:)];
        else
            fname = folder;
        end
        
        temp = double(ncread(fname,varname));
        switch ndims(temp)
            case 2
                out(k:k+length(temp)-1) = temp;
                k = k+length(temp);
            case 3
                out(:,:,k:k+size(temp,3)-1) = temp;
                k = k+size(temp,3);
            case 4
                out(:,:,:,k:k+size(temp,4)-1) = temp;
                k = k+size(temp,4);
        end        
    end   
    