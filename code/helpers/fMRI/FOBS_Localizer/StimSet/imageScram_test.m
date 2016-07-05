function imageScram(folder1,folder2,n,num_regions,neib,fmt,gridScram,fcolor,gs,sufs,folder3,fftstd)
% IMAGESCRAM.M
% imageScram(folder1,folder2,n,[neib,fmt,gridScram,fcolor,gsx,sufs,folder3,fftstd])
%
% folder1 = source folder
% folder2 = destination folder
% These folders should be in the same root directory, from which imageScram
% 	should be executed. Source should contain only image files. Images should
%   be in a recognizable format (e.g. bmp, tif, jpg).
% n = number of divisions for scrambling
% neib (optional)
%	GRID-Scrambling Routines [0-4]
%   0: scrambling is a completely random permutation of the grid (default).
%	1: neighbouring pairs of grid squares are exchanged diagonally.
%	2: exchanged vertically.
%	3: exchanged horizontally.
%	4: exchanged with the grid square of closest average luminance.
%   FFT-Scrambling Routines  [5-7]
%   FFT amplitude is from original image. 24bit colour images are converted
%       to greyscale. 8bit colour images are scrambled as greyscale, but then
%       have the colour map arbitrarily remapped to the new scrambled values.
%   5: FFT phase information is sampled randomly from a normal disctribution.
%   6: FFT phase information is taken from the image, but scrambled.
%   7: Random adjustment to FFT phase information based on fftstd value.
% fmt (optional) = output image format - recommended are 'bmp', 'tif', 'jpg'
%	Default fmt='bmp'
% gridScram (optional)
%	0: does not put a grid over scrambled images (default).
%	1: puts grid over scrambled images before saving to disk.
%	2:, saves both grid and non-grid scrambled versions in folder2
%		with suffixes "_gscr.ext" and "_scrm.ext".
%	3: same as 2, plus intact grid images saved in folder2
%		with suffix "_gint.ext".
%	4: saves "_gint.ext" and "_gscr.ext" only in folder2.
%	note: the delimiter (e.g. "_") must be supplied if wanted.
% fcolor (optional) = grid color - can by 0-255 or rgb triplet [x y z]
% 	Default fcolor=white [255 255 255] or white from 8-bit clut.
% gs (optional) = grid size - size of grid lines in pixels
% 	Default gs=3;
% sufs (optional) = cell string array containing suffixes.
%	sufs(1)=suffix for intact grid objects.
%	sufs(2)=suffix for scrambled grid objects.
%	sufs(3)=suffix for scrambled non-grid objects.
%	Default: sufs={'_gint' '_gscr' '_scrm'};
% folder3 (optional) = destination folder for intact grid images
% 	If folder3 parameter is present, images will be saved
%	to folder3 with no suffix. This does not override the gridScram
%	parameter, so it is possible to save these to disk twice with different
%	filenames.
% fftstd (optional) = NOT optional if neib=>5. Std of distribution about a mean of zero
%   from which are added to phase spectrum of image. Default: fftstd = 3*pi/4.
%
% Images in folder1 (source) do not have to be the the same format. Setting fmt='same'
%	will preserve differences in format of destination images (folder2). If images
%	do not have the same number of color bits (e.g. 8-bit), then grid color cannot
%	be specified.
%
% Tested well with greyscale 8-bit bmp images outputting to bmp, tif and jpg.
% 	Jpgs do not support 8-bit files (thus they are supersampled to 24-bit).
%
% Tested well with 8-bit color bmp images outputting to bmp, tif and jpg,
%	and with tif outputted to tif. Again, jpgs were supersampled to 24-bit.
%
% Tested well with 24-bit color jpg, bmp, tif images outputting to same format.
%
% Grid color is tricky with 8-bit color. Make sure that you understand the color table
%	index before trying this, even with greyscale images. In photoshop, go to
%	IMAGE > MODE > COLOR TABLE
%
% Examples:
%
% imageScram('pics1','gridscr',16,4);
%
% imageScram('pics1','fftscr',[],7,[],[],[],[],[],[],pi/2);
%
%
% Written by Thomas James <tom.james@vanderbilt.edu> Sept. 2002
%
% Enhancements based on suggestions by Jody Culham on Oct. 9 2002
%	- added suffix support for output
%	- grid to include perimeter of object
%	- added more methods of scrambling, besides just random exchange
%
% Enhancement on May 17 2004
%   - FFT-scrambling routine added (neib=5,6)

% <<< check for existence and range of variables >>>
fprintf('Got this far 1!\n');
if exist(folder1)~=7,
	error('Source folder does not exist! Stopping.')
end
if exist(folder2)~=7,
	errordlg('Destination folder does not exist. Creating.','Create Folder')
	mkdir(folder2);
end
if ~exist('fmt'),fmt=[];end
if ~exist('num_regions'),num_regions=[];end
if ~exist('neib'),neib=[];end
if ~exist('fcolor'),fcolor=[];end
if ~exist('gs'),gs=[];end
if ~exist('folder3'),folder3=[];end
if ~exist('sufs'),sufs=[];end
if ~exist('gridScram'),gridScram=[];end
if ~exist('fftstd'),fftstd=3*pi/4;end
if n<2,
	errordlg('Divisions less than two! Continuing with n=2.','N=2')
	n=2;
end
if isempty(neib),
	neib=0;
elseif neib>7,
	error('neib value is >7. Stopping.');
end
if isempty(gridScram),
	gridScram=0;
elseif gridScram>4,
	error('gridScram value is >4. Stopping.');
end
if isempty(sufs),sufs={'_gint' '_gscr' '_scrm'};end
if isempty(fmt),
	fmt='bmp';
elseif ~findstr(fmt,'bmp tif jpg'),
	errordlg('Not using one of the recommended image formats.','Image Formats')
end
fprintf('Got this far 2!, neib=%d\n',neib);
% <<< MAIN LOOP >>>
d=dir(strcat(pwd,'/',folder1));
fprintf('pwd= %s,folder1 = %s, d = \n',pwd,folder1);
fprintf('Got this far 1! length(d)=%d\n',length(d));
for i=3:length(d),
	fname=char(d(i).name);
	[A,Col]=imread(strcat(pwd,'/',folder1,'/',fname));
	A=double(A);
	sx=size(A,1);sy=size(A,2);
	% <<< resolve scrambling technique GRID or FFT >>>
	if neib>=5,
		% <<< fft-scrambling routine >>>
        %*****************
        fprintf('Got this far!\n');
		MAP=double(Col);
		% convert to greyscale
		if size(A,3)==1,
			% from 8bit colour
			map=255*mean(MAP,2);
			A=map(A+1);
		elseif size(A,3)==3,
			% from 24bit colour
			A=mean(A,3);
			x=(0:255)/255;Col=[x' x' x'];
		else
			error('Wrong color table - unrecognized image type!')
		end
		% fft for amplitude spectrum
		F=fft2(A);
		AMP=abs(F);
		% <<< resolve fft-scrambling technique >>>
		if neib==5,
			% fft of random noise for phase spectrum
			A=randn(size(F));
			F=fft2(A);
			PH=angle(F);
		elseif neib==6,
			% scramble phase spectrum of image
			B=angle(F);
			b=reshape(B,size(B,1)*size(B,2),1);
			rr=randperm(length(b));
			PH=reshape(b(rr),size(B,1),size(B,2));
		elseif neib==7,
			% add random shift to phase (fftstd)
			B=angle(F);
			DEV=randn(size(B))*fftstd;
			PH=B+DEV;
		end
		% make new stimulus
		M1=abs(AMP).*(cos(PH)+sqrt(-1).*sin(PH));
		M2=ifft2(M1);
		M3=real(M2);
		B=127+M3-mean(mean(M3));
		B(find(B>255))=255;
		B(find(B<0))=0;
	else
		if sx/n~=fix(sx/n),error(sprintf('Dimensions do not agree with divisions for %s, %d divisions versus %d pixels',fname,n,sx)),end
		if sy/n~=fix(sy/n),error(sprintf('Dimensions do not agree with divisions for %s, %d divisions versus %d pixels',fname,n,sy)),end
		bx=sx/n;by=sy/n;
		% <<< resolve grid-scrambling technique by assigning variable rr >>>
		if neib==0,
			rr=randperm(n^2);
        elseif neib == -1,
            if isempty(num_regions), error(sprintf('Number of weighting regions not specified')),end
            if n/(num_regions*2)~=fix(n/(num_regions*2)),error(sprintf('Grid dimension is not a multiple of weighting regions')),end
            %set number of concentric regions in image
            %num_regions = 4;
            ring_width = n/(num_regions*2);
            ring_map  = zeros(n);
            for this_region = 1:num_regions-1,
                upper_right = ring_width*this_region+1;
                lower_left = n-ring_width*this_region;
                ring_map(upper_right:lower_left,upper_right:lower_left) = this_region;

            end   
            for this_region = 0:num_regions-1,
                this_ring_positions = find(ring_map==this_region);
                permutation_list = randperm(numel(this_ring_positions));
                rr(this_ring_positions) = this_ring_positions(permutation_list);
            end
                
                  
		elseif neib==1, % diagonal
			for j=1:fix(n/2),
				for i=1:fix(n/2),
					rr((j-1)*2*n+(i-1)*2+1	  )	=(j-1)*2*n+(i-1)*2+1 	+n+1;
					rr((j-1)*2*n+i*2		  )	=(j-1)*2*n+i*2 			+n-1;
					rr((j-1)*2*n+(i-1)*2+1 	+n)	=(j-1)*2*n+(i-1)*2+1 	+1;
					rr((j-1)*2*n+i*2 		+n)	=(j-1)*2*n+i*2 			-1;
				end
			end
		elseif neib==2, % vertical
			for j=1:fix(n/2),
				for i=1:n,
					rr((j-1)*2*n+i	  )	=(j-1)*2*n+i 	+n;
					rr((j-1)*2*n+i 	+n)	=(j-1)*2*n+i 	;
				end
			end
		elseif neib==3, % horizontal
			for j=1:n,
				for i=1:fix(n/2),
					rr((j-1)*n+(i-1)*2+1)=(j-1)*n+i*2;
					rr((j-1)*n+i*2)=(j-1)*n+(i-1)*2+1;
				end
			end
		else			% luminance
			if size(A,3)>1,AG=mean(A,3);else,AG=A;end
			for j=1:n,
				for i=1:n,
					L=AG((i-1)*bx+1:i*bx,(j-1)*by+1:j*by,:);
					lumins((j-1)*n+i)=mean(mean(L));
				end
			end
			clear AG L ll
			[lumins lindex]=sort(lumins);
			for i=1:fix(n^2/2),
				rr(lindex(i*2-1))=lindex(i*2);
				rr(lindex(i*2))=lindex(i*2-1);
			end
		end
		% <<< grid-scrambling routine >>>
		B=zeros(size(A));
		if size(A,3)==3,
			for j=1:length(rr),
				vy=fix((j-1)/n)+1;
				vx=j-(vy-1)*n;
				vyr=fix((rr(j)-1)/n)+1;
				vxr=rr(j)-(vyr-1)*n;
				B((vx-1)*bx+1:vx*bx,(vy-1)*by+1:vy*by,:)=A((vxr-1)*bx+1:vxr*bx,(vyr-1)*by+1:vyr*by,:);
			end
		elseif size(A,3)==1,
			for j=1:length(rr),
				vy=fix((j-1)/n)+1;
				vx=j-(vy-1)*n;
				vyr=fix((rr(j)-1)/n)+1;
				vxr=rr(j)-(vyr-1)*n;
				B((vx-1)*bx+1:vx*bx,(vy-1)*by+1:vy*by)=A((vxr-1)*bx+1:vxr*bx,(vyr-1)*by+1:vyr*by);
			end
		else
			error('Wrong color table - unrecognized image type!')
		end
	end
	% <<< if GRID objects are required >>>
	if ~isempty(folder3) | gridScram,
		% set default values if none are specified
		if isempty(fcolor),
			if size(A,3)==3,
				fcolor=[255 255 255];
			else
				findcol=find(Col(:,1)==1 & Col(:,2)==1 & Col(:,3)==1);
				if ~isempty(findcol),
					fcolor=findcol(1)-1;
				else
					fcolor=255;
				end
			end
		end
		if isempty(gs),
			gs=3;
		end
		if size(A,3)==3 & length(fcolor)~=3,
			error('Grid color (fcolor) is not appropriate number of bits')
		end
		% make grid
		gsEven= gs/2==fix(gs/2);
		gs2=fix(gs/2);
		G=zeros(size(A));
		for i=1:n-1,
			for m=1:size(A,3),
				G(i*bx-gs2+gsEven:i*bx+gs2,:,m)=1;
				G(:,i*by-gs2+gsEven:i*by+gs2,m)=1;
				G(1:gs,:,m)=1;
				G(:,1:gs,m)=1;
				G(sx-gs+1:sx,:,m)=1;
				G(:,sy-gs+1:sy,m)=1;
			end
		end
		G=squeeze(G);
		% get grid coordinates for applying grid to images
		if size(G,3)==3,
			[ffgx,ffgy]=find(G(:,:,1)==1 & G(:,:,2)==1 & G(:,:,3)==1);
		else
			ffg=find(G==1);
		end
	end

	% <<< write images to disk [folder2] >>>
	% evaluate gridScram variable
	if gridScram,
		% superimpose grid on scrambled image
		C=B;
		if size(C,3)==3,
			for ii=1:length(ffgx),
				C(ffgx(ii),ffgy(ii),:)=fcolor;
			end
		else
			C(ffg)=fcolor;
		end
		if gridScram==1,
			saveToDisk(fname,[],C,fmt,Col,folder2);
		elseif gridScram==2,
			saveToDisk(fname,char(sufs(2)),C,fmt,Col,folder2);
			saveToDisk(fname,char(sufs(3)),B,fmt,Col,folder2);
		elseif gridScram==3,
			D=A;
			if size(D,3)==3,
				for ii=1:length(ffgx),
					D(ffgx(ii),ffgy(ii),:)=fcolor;
				end
			else
				D(ffg)=fcolor;
			end
			saveToDisk(fname,char(sufs(2)),C,fmt,Col,folder2);
			saveToDisk(fname,char(sufs(3)),B,fmt,Col,folder2);
			saveToDisk(fname,char(sufs(1)),D,fmt,Col,folder2);
		else
			D=A;
			if size(D,3)==3,
				for ii=1:length(ffgx),
					D(ffgx(ii),ffgy(ii),:)=fcolor;
				end
			else
				D(ffg)=fcolor;
			end
			saveToDisk(fname,char(sufs(2)),C,fmt,Col,folder2);
			saveToDisk(fname,char(sufs(1)),D,fmt,Col,folder2);
		end
	else
		saveToDisk(fname,[],B,fmt,Col,folder2);
	end

	% regarless of variable gridScram,
	% write intact grid images to folder3 if folder3 argument exists.
	if ~isempty(folder3),
		if exist(folder3)~=7,
			errordlg('Grids folder does not exist. Creating.','Create Folder')
			mkdir(folder3);
		end
		D=A;
		if size(D,3)==3,
			for ii=1:length(ffgx),
				D(ffgx(ii),ffgy(ii),:)=fcolor;
			end
		else
			D(ffg)=fcolor;
		end
		saveToDisk(fname,[],D,fmt,Col,folder3);
	end
end

% development notes
% sx, sy: size in pixels of image
% bx, by: size in pixels of grid squares
% vx, vy: indices of grid squares (in "grid space" not pixel space)
% A: source image
% B: output image
% G: grid image
% ffg, ffgx, ffgy: indices of grid pixels in G
% rr: lookup table for exchanging grid squares
% Col: color lookup table for 8bit images

% SUB-FUNCTIONS
function errVal=saveToDisk(fname,suffix,IMG,fmt,Col,folder)
fext=find(fname=='.');
if isempty(fext),
	if strcmp(fmt,'same'),
		error('No extension found. Format cannot be determined')
		errVal=1;return
	else
		if isempty(suffix),
			filespec=sprintf('%s/%s/%s',pwd,folder,fname);
		else
			filespec=sprintf('%s/%s/%s%s',pwd,folder,fname,suffix);
		end
	end
	if size(IMG,3)==3,
		imwrite(uint8(IMG),filespec,fmt);
	else
		imwrite(uint8(IMG),Col,filespec,fmt);
	end
else
	theExt=fname(fext(length(fext))+1:length(fname));
	fnameRoot=fname(1:fext(length(fext))-1);
	if strcmp(theExt,fmt) | strcmp(fmt,'same'),
		if isempty(suffix),
			filespec=sprintf('%s/%s/%s',pwd,folder,fname);
		else
			filespec=sprintf('%s/%s/%s%s.%s',pwd,folder,fnameRoot,suffix,theExt);
		end
	else
		if isempty(suffix),
			filespec=sprintf('%s/%s/%s.%s',pwd,folder,fnameRoot,fmt);
		else
			filespec=sprintf('%s/%s/%s%s.%s',pwd,folder,fnameRoot,suffix,fmt);
		end
    end
    %fprintf('imagespec=%s',filespec);
	if size(IMG,3)==3,
		imwrite(uint8(IMG),filespec);
	else
		imwrite(uint8(IMG),Col,filespec);
	end
end
errVal=0;
return


