function noiseTex = makeNoiseTexture(windowPtr, numPatches, rectToFill, noiseSquareWidth, scale)
% modeled off of FastNoiseDemo
%
% numRects = Number of random patches to generate and draw per frame.
%
% rectSize = Size of the generated random noise image: rectSize by rectSize
%            pixels. This is also the size of the Psychtoolbox noise
%            texture.
%
% scale = Scalefactor to apply to texture during drawing: E.g. if you'd set
% scale = 2, then each noise pixel would be replicated to draw an image
% that is twice the width and height of the input noise image. In this
% demo, a nearest neighbour filter is applied, i.e., pixels are just
% replicated, not bilinearly filtered -- Important to preserve statistical
% independence of the random pixel values!
%

% Abort script if it isn't executed on Psychtoolbox-3:
AssertOpenGL;

% Assign default values for all unspecified input parameters:
if nargin < 1 || isempty(windowPtr)
    windowPtr = 0;
end
if nargin < 2 || isempty(numPatches)
    numPatches = 1; % Draw one noise patch by default.
end

if nargin < 3 || isempty(rectToFill)
    rectToFill = [0 0 1024 768];
end

if nargin < 4 || isempty(noiseSquareWidth)
    noiseSquareWidth = 128; % Default patch size is 128 by 128 noisels.
end

if nargin < 5 || isempty(scale)
    scale = 1; % Don't up- or downscale patch by default.
end


syncToVBL = 1; % Synchronize to vertical retrace by default.


if syncToVBL > 0
    asyncflag = 0;
else
    asyncflag = 2;
end

if nargin < 5 || isempty(dontclear)
    dontclear = 0; % Clear backbuffer to background color by default after each bufferswap.
end

if dontclear > 0
    % A value of 2 will prevent any change to the backbuffer after a
    % bufferswap. In that case it is your responsibility to take care of
    % that, but you'll might save up to 1 millisecond.
    dontclear = 2;
end

% 
% % Open fullscreen onscreen window on that screen. Background color is
% % gray, double buffering is enabled. Return a 'win'dowhandle and a
% % rectangle 'winRect' which defines the size of the window:
% [windowPtr, winRect] = Screen('OpenWindow', 1, 128);

% Compute destination rectangle locations for the random noise patches:

% 'objRect' is a rectangle of the size 'rectSize' by 'rectSize' pixels of
% our Matlab noise image matrix:
objRect = SetRect(0,0, noiseSquareWidth, noiseSquareWidth);

% ArrangeRects creates 'numRects' copies of 'objRect', all nicely
% arranged / distributed in our window of size 'winRect':
patchRects = ArrangeRects(numPatches, objRect, rectToFill);

% Now we rescale all rects: They are scaled in size by a factor 'scale':
for i=1:numPatches
    % Compute center position [xc,yc] of the i'th rectangle:
    [xc, yc] = RectCenter(patchRects(i,:));
    % Create a new rectange, centered at the same position, but 'scale'
    % times the size of our pixel noise matrix 'objRect':
    patchRects(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
end

noisestdev = 50;

for i=1:numPatches
    % Compute noiseimg noise image matrix with Matlab:
    % Normally distributed noise with mean 128 and stddev. 50, each
    % pixel computed independently:
    noiseimg=(noisestdev*randn(noiseSquareWidth, noiseSquareWidth) + 128);
    
    % Convert it to a texture 'tex':
    noiseTex=Screen('MakeTexture', windowPtr, noiseimg);
    
    % Draw the texture into the screen location defined by the
    % destination rectangle 'dstRect(i,:)'. If dstRect is bigger
    % than our noise image 'noiseimg', PTB will automatically
    % up-scale the noise image. We set the 'filterMode' flag for
    % drawing of the noise image to zero: This way the bilinear
    % filter gets disabled and replaced by standard nearest
    % neighbour filtering. This is important to preserve the
    % statistical independence of the noise pixels in the noise
    % texture! The default bilinear filtering would introduce local
    % correlations when scaling is applied:
    Screen('DrawTexture', windowPtr, noiseTex, [], patchRects(i,:), [], 0);
    
    % After drawing, we can discard the noise texture.
    Screen('Close', noiseTex);
end
