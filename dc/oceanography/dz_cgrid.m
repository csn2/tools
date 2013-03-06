%   Calculates z derivative on a stretched grid
%       [dvdz] = dz_cgrid(grid,var)
%           grid is a structure with s (s for var), s_w, zw

function [dvdz] = dz_cgrid(grid,var)

    dvds = nan(size(var));
    dvds(:,:,2:end-1,:) = avg1(bsxfun(@rdivide,diff(var,1,3),permute(diff(grid.s'),[3 2 1])),3);
    
    % pad on bottom and surface values - IN S
   ds1 = (grid.s(2)-grid.s(1))./(grid.s(3)-grid.s(2));
   ds2 = (grid.s(end)-grid.s(end-1))./(grid.s(end-1) - grid.s(end-2));
   dvds(:,:,1,:)   = dvds(:,:,2,:) - (dvds(:,:,3,:) - dvds(:,:,2,:))*ds1;
   dvds(:,:,end,:) = dvds(:,:,end-1,:) + (dvds(:,:,end-1,:)-dvds(:,:,end-2,:))*ds2;
    
    if size(grid.zw,1)-1 == size(var,3)
        grid.zw = permute(grid.zw,[3 2 1]);
    end

    Hz = bsxfun(@rdivide,diff(grid.zw,1,3),permute(diff(grid.s_w',1,1),[3 2 1]));
    
    if size(Hz,1) ~= size(dvds,1)
        Hz = avg1(Hz,1);
    end
    if size(Hz,2) ~= size(dvds,2)
        Hz = avg1(Hz,2);
    end

    dvdz = 1./Hz .* dvds;
    
    % pad on bottom and surface values - IN Z - seems to work better than s
    dz1 = (grid.zmat(:,:,2)-grid.zmat(:,:,1))./(grid.zmat(:,:,3) - grid.zmat(:,:,2));
    dz2 = (grid.zmat(:,:,end)-grid.zmat(:,:,end-1))./(grid.zmat(:,:,end-1) - grid.zmat(:,:,end-2));
    
    dvdz(:,:,1,:)   = dvdz(:,:,2,:) - ...
                        bsxfun(@times,dvdz(:,:,3,:) - dvdz(:,:,2,:),dz1);
    dvdz(:,:,end,:) = dvdz(:,:,end-1,:) + ...
                        bsxfun(@times,dvdz(:,:,end-1,:)-dvdz(:,:,end-2,:),dz2);
                    
    debug = 0;
    
    if debug
        figure
        ax(1) = subplot(141);
        pcolorcen(squeeze(grid.xmat(:,1,:))/1000,squeeze(grid.zmat(:,1,:)),squeeze(1./Hz(:,1,:)));
        shading flat; title('1/Hz = 1/height of grid cell'); colorbar
        ax(2) = subplot(142);
        pcolorcen(squeeze(grid.xmat(:,1,:))/1000,squeeze(grid.zmat(:,1,:)),squeeze(dvds(:,1,:)));
        title('d/ds'); colorbar;shading flat
        ax(3) = subplot(143);
        pcolorcen(squeeze(grid.xmat(:,1,:))/1000,squeeze(grid.zmat(:,1,:)),squeeze(dvdz(:,1,:)));
        title('d/dz = 1/Hz * d/ds'); colorbar; shading flat
        ax(4) = subplot(144);
        pcolorcen(squeeze(grid.xmat(:,1,:))/1000,squeeze(grid.zmat(:,1,:)),squeeze(zeros(size(grid.xmat(:,1,:)))));
        shading faceted
        linkaxes(ax,'xy');
    end