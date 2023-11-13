using LinearAlgebra, Images

function getRGBchannels(rgbimg)
    channels = channelview(rgbimg)
    redChannel = channels[1,:,:]
    greenChannel = channels[2,:,:]
    blueChannel = channels[3,:,:]
    return redChannel, greenChannel, blueChannel
end

function getTorusLaplacian(nrows, degreeOfRegularity)
    if mod(degreeOfRegularity,2) == 1
       println("Adding a single connection to get an even degree.")
       degreeOfRegularity += 1
    end # if
    #L = -degreeOfRegulatity*Matrix(I,nrows,nrows)
    L = -degreeOfRegularity*diagm(ones(nrows))
    for k in 1:div(degreeOfRegularity,2)
      L += diagm(k => ones(nrows - k), -k => ones(nrows -k))
      L += diagm((nrows - k) => ones(k), (k-nrows) => ones(k))
    end #for
    return L
end

function walk(channel, time, rowLaplacian, columnLaplacian)
    U1 = exp(-1im*time*rowLaplacian)
    U2 = exp(-1im*time*columnLaplacian)
    temp = U1*channel*U2
    newimg = map(x -> minimum([1,x]), norm.(temp))
    return newimg
 end

 function showNewImage(originalImage, time, rowLaplacian, columnLaplacian)
    channels = channelview(originalImage)
    rc = channels[1,:,:]
    gc = channels[2,:,:]
    bc = channels[3,:,:]
    newrc = walk(rc, time, rowLaplacian, columnLaplacian)
    newgc = walk(gc, time, rowLaplacian, columnLaplacian)
    newbc = walk(bc, time, rowLaplacian, columnLaplacian)
    nrows, ncols = size(rc)
    newimg = []
    for c in 1:ncols
        for r in 1:nrows
            push!(newimg,RGB{Float32}(newrc[r,c],newgc[r,c],newbc[r,c]))
        end
    end
    newimg = reshape(newimg, (nrows,ncols))
    return RGB{Float32}.(newimg)
end


 function saveImages(img,numsteps;regularity = 2, basepath = "C:/Users/Student5/Desktop/btc_quantum.png",grayScale = true)
    rc,gc,bc = getRGBchannels(img)
    rLap =getTorusLaplacian(size(rc)[1],2)
    cLap = getTorusLaplacian(size(rc)[2],2)
    if grayScale == true
        img0 = rc
    else
        img0 = img
    end
    for k=1:numsteps
        numberLabel = string(1000 + k,".png")[2:end]
        picName = string(basepath,numberLabel)
        if grayScale == true
            newimg = Gray.(walk(img0,k*pi/5,rLap,cLap))
            save(picName,newimg)
        else
            newimg = showNewImage( img0,k*pi/5,rLap,cLap)
            save(picName,newimg)
        end #grayscale test
    end #for loop
    return 
end

#=

Here's how we do it manually
img0 = Images.load("/home/clark/mom-n-pop-qm-shop/images/BW/bw23.png")
#this is a black and white image, so we take only the red channel
rc,gc,bc = getRGBchannels(img0)
rLap = getTorusLaplacian(sizr(rc)[1],2)
cLap = getTorusLaplacian(sizr(rc)[2],2)

newimg = walk()

=#

        