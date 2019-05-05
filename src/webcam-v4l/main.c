#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <linux/videodev2.h>

int main (int argc, char *argv[])
{
    (void) argc;
    (void) argv;

    const char *dev_name = "/dev/video0";

    // 1. Open device
    int file_dev = open(dev_name, O_RDWR);
    if (file_dev < 0) {
        printf ("%s error %d, %s\n", dev_name, errno, strerror(errno));
        return errno;
    }

    // 2. Ask the device if it can capture frames
    struct v4l2_capability dev_caps;
    if (ioctl(file_dev, VIDIOC_QUERYCAP, &dev_caps) < 0) {
        printf ("\"VIDIOC_QUERYCAP\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }


    printf("driver: %s\n", dev_caps.driver);
    printf("card: %s\n", dev_caps.card);
    printf("bus_info: %s\n", dev_caps.bus_info);
    printf("version: %d.%d.%d\n",
         ((dev_caps.version >> 16) & 0xFF),
         ((dev_caps.version >> 8) & 0xFF),
         (dev_caps.version & 0xFF));
    printf("capabilities: 0x%08x\n", dev_caps.capabilities);
    printf("device capabilities: 0x%08x\n", dev_caps.device_caps);

    // 3. Set image format
    struct v4l2_format stream_data_format;
    stream_data_format.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    stream_data_format.fmt.pix.width = 640;
    stream_data_format.fmt.pix.height = 480;
    stream_data_format.fmt.pix.pixelformat = V4L2_PIX_FMT_MJPEG;
    stream_data_format.fmt.pix.field = V4L2_FIELD_NONE;
    // tell the device you are using this format
    if(ioctl(file_dev, VIDIOC_S_FMT, &stream_data_format) < 0){
        printf ("\"VIDIOC_S_FMT\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }

    // 4. Request buffers from the device
    struct v4l2_requestbuffers request_buf;
    request_buf.count = 1; // one request buffer
    request_buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE; // request a buffer wich we an use for capturing frames
    request_buf.memory = V4L2_MEMORY_MMAP;

    if(ioctl(file_dev, VIDIOC_REQBUFS, &request_buf) < 0){
        printf ("\"VIDIOC_REQBUFS\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }

    // 5. Quety the buffer to get raw data ie. ask for the you requested buffer
    // and allocate memory for it
    struct v4l2_buffer query_buf;
    query_buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    query_buf.memory = V4L2_MEMORY_MMAP;
    query_buf.index = 0;
    if(ioctl(file_dev, VIDIOC_QUERYBUF, &query_buf) < 0){
        printf ("\"VIDIOC_QUERYBUF\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }

    // use a pointer to point to the newly created buffer
    // mmap() will map the memory address of the device to
    // an address in memory
    char *buf = (char *) mmap(
                NULL, query_buf.length, PROT_READ | PROT_WRITE, MAP_SHARED,
                        file_dev, query_buf.m.offset);
    if (buf == NULL) {
        printf ("\"mmap\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }

    memset(buf, 0, query_buf.length);

    // 6. Get a frame
    // Create a new buffer type so the device knows whichbuffer we are talking about
    struct v4l2_buffer buf_info;
    memset(&buf_info, 0, sizeof(buf_info));
    buf_info.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf_info.memory = V4L2_MEMORY_MMAP;
    buf_info.index = 0;

    // Activate streaming
    int type = buf_info.type;
    if(ioctl(file_dev, VIDIOC_STREAMON, &type) < 0){
        printf ("\"VIDIOC_STREAMON\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }

    // Queue the buffer
    if(ioctl(file_dev, VIDIOC_QBUF, &buf_info) < 0){
        printf ("\"VIDIOC_QBUF\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }

    // Dequeue the buffer
    if(ioctl(file_dev, VIDIOC_DQBUF, &buf_info) < 0){
        printf ("\"VIDIOC_DQBUF\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }
    // Frames get written after dequeuing the buffer

    printf("buffer has: %f KBytes of data\n", buf_info.bytesused / 1024.0);

    // Write the data out to file
    FILE *f = fopen("webcam_output.jpeg", "wb");
    if (f == NULL) {
        printf ("\"fopen\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }

    int bufPos = 0, outFileMemBlockSize = 0;  // the position in the buffer and the amoun to copy from
                                        // the buffer
    int remainingBufferSize = buf_info.bytesused; // the remaining buffer size, is decremented by
                                                    // memBlockSize amount on each loop so we do not overwrite the buffer
    char *outFileMemBlock = NULL;  // a pointer to a new memory block
    int itr = 0; // counts thenumber of iterations
    while(remainingBufferSize > 0) {
        bufPos += outFileMemBlockSize;  // increment the buffer pointer on each loop
                                        // initialise bufPos before outFileMemBlockSize so we can start
                                        // at the begining of the buffer

        outFileMemBlockSize = 1024;    // set the output block size to a preferable size. 1024 :)
        outFileMemBlock = (char *) malloc(sizeof(char) * outFileMemBlockSize);

        // copy 1024 bytes of data starting from buffer+bufPos
        memcpy(outFileMemBlock, buf+bufPos, outFileMemBlockSize);
        fwrite(outFileMemBlock, 1, outFileMemBlockSize, f);

        // calculate the amount of memory left to read
        // if the memory block size is greater than the remaining
        // amount of data we have to copy
        if(outFileMemBlockSize > remainingBufferSize)
            outFileMemBlockSize = remainingBufferSize;

        // subtract the amount of data we have to copy
        // from the remaining buffer size
        remainingBufferSize -= outFileMemBlockSize;

        // display the remaining buffer size
        printf("%d Remaining bytes: %d\n", itr++, remainingBufferSize);
    }

    // Close the file
    fclose(f);

    // end streaming
    if(ioctl(file_dev, VIDIOC_STREAMOFF, &type) < 0){
        printf ("\"VIDIOC_STREAMOFF\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }

    // 3. Close device
    if (close(file_dev)) {
        printf ("\"close\" error %d, %s\n", errno, strerror(errno));
        return errno;
    }

    return 0;
}
