#import "ViewController.h"

#import <GLKit/GLKit.h>

#import "GMacros.h"
#import "GShader.h"

@implementation ViewController
{
    OpenGLView *glView;
    GShader *shader;
    
    AVCaptureDevice *captureDevice;
    AVCaptureDeviceInput *deviceInput;
    AVCaptureSession *session;
    AVCaptureVideoDataOutput *videoOutput;
    
    CVOpenGLESTextureCacheRef textureCache;
    CVOpenGLESTextureRef textureObject;
    float videoAspect;
    
    //RealTime
    NSDate *beginTime;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize opengl
    glView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:glView];
    glView.glViewDelegate = self;
    [glView startRendering];
    
    NSString *vs = SHADER_STRING(
                                 attribute vec4 position;
                                 attribute vec2 texcoord;
                                 varying highp vec2 uv;
                                 void main()
                                 {
                                     uv = texcoord;
                                     gl_Position = position;
                                 }
                                 );
    
    /* basics */
//    NSString *fs = SHADER_STRING(
//                                 precision highp float;
//                                 
//                                 uniform sampler2D videoInput;
//                                 uniform float iGlobalTime;
//                                 uniform vec2 iResolution;
//                                 
//                                 varying highp vec2 uv;
//                                 void main()
//                                 {
//                                     vec2 unused1 = iResolution;
//                                     float unused2 = iGlobalTime;
//                                     
//                                     gl_FragColor = texture2D(videoInput, uv);
//                                     /*gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);*/
//                                 }
//                                 );
    
    /* wave! */
    NSString *fs = SHADER_STRING(
                                 precision highp float;
                                 
                                 uniform sampler2D videoInput;
                                 uniform float iGlobalTime;
                                 uniform vec2 iResolution;
                                 
                                 varying vec2 uv;
                                 void main()
                                 {
                                     vec2 unused = iResolution;
                                     
                                     float stongth = sin(iGlobalTime) * 0.5 + 0.5;
                                     float waveu = sin((uv.y + iGlobalTime) * 20.0) * 0.5 * 0.1 * stongth;
                                     gl_FragColor = texture2D(videoInput, uv + vec2(waveu, 0));
                                 }
                                 );
    
    /* real time separate RGB */
//    NSString *fs = SHADER_STRING(
//                                 precision highp float;
//                                 
//                                 uniform sampler2D videoInput;
//                                 uniform float iGlobalTime;
//                                 uniform vec2 iResolution;
//                                 
//                                 varying vec2 uv;
//                                 
//                                 void main(void)
//                                 {
//                                     vec2 unused = iResolution;
//                                     
//                                     float blurx = sin(iGlobalTime) * 0.5 + 0.5;
//                                     float offsetx = blurx * 0.05;
//                                     
//                                     vec2 ruv = uv + vec2(offsetx, 0.0);
//                                     vec2 guv = uv;
//                                     vec2 buv = uv - vec2(offsetx, 0.0);
//                                     
//                                     float r = texture2D(videoInput, ruv).r;
//                                     float g = texture2D(videoInput, guv).g;
//                                     float b = texture2D(videoInput, buv).b;
//                                     
//                                     gl_FragColor = vec4(r, g, b, 1.0);
//                                 }
//                                 );
    
    
    /* real time edge detection */
//    NSString *fs = SHADER_STRING(
//                                 precision highp float;
//                                 
//                                 uniform sampler2D videoInput;
//                                 uniform float iGlobalTime;
//                                 uniform vec2 iResolution;
//                                 
//                                 varying vec2 uv;
//                                 
//                                 float gray(vec4 color)
//                                 {
//                                     return (color.r + color.g + color.b) * 0.33333333;
//                                 }
//                                 
//                                 void main(void)
//                                 {
//                                     float unused = iGlobalTime;
//                                     
//                                     float pixelwide = 1.0 / iResolution.x;
//                                     float pixelhigh = 1.0 / iResolution.y;
//                                     
//                                     vec4 c = texture2D(videoInput, uv);
//                                     float c_value = gray(c);
//                                     
//                                     vec4 l = texture2D(videoInput, uv + vec2(-pixelwide, 0.0));
//                                     vec4 u = texture2D(videoInput, uv + vec2(0.0, pixelhigh));
//                                     vec4 r = texture2D(videoInput, uv + vec2( pixelwide, 0.0));
//                                     vec4 b = texture2D(videoInput, uv + vec2(0.0, -pixelhigh));
//                                     
//                                     float difference = 0.0;
//                                     
//                                     difference = max(difference, abs(c_value - gray(l)));
//                                     difference = max(difference, abs(c_value - gray(u)));
//                                     difference = max(difference, abs(c_value - gray(r)));
//                                     difference = max(difference, abs(c_value - gray(b)));
//                                     
//                                     difference = clamp(difference * 20.0, 0.0, 1.0);
//                                     
//                                     gl_FragColor = vec4(difference, difference, difference, 1.0);
//                                 }
//                                 );
    


    
    NSError *error;
    shader = [GShader shaderWithVertexShader:vs fragmentShader:fs error:&error];
    if(error)
    {
        NSLog(@"%@", error);
    }
    
    //initialize camera
    @try {
        [self initializeCamera];
    }
    @catch (NSException *exception) {
        NSLog(@"camera init error : %@", exception);
    }
    @finally {

    }
    
    beginTime = [NSDate date];
}

- (void)initializeCamera
{
    for(AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
    {
        if(device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
        }
    }
    
    if(captureDevice == nil)
    {
        [NSException raise:@"" format:@"AVCaptureDevicePositionBack not found"];
    }
    
    NSError *error;
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    session = [[AVCaptureSession alloc] init];
    
    [session beginConfiguration];
    {
//        session.sessionPreset = AVCaptureSessionPresetHigh;
        session.sessionPreset = AVCaptureSessionPresetMedium;
//        session.sessionPreset = AVCaptureSessionPresetLow;
        
        [session addInput:deviceInput];
        
        videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        videoOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
        [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        [session addOutput:videoOutput];
    }
    [session commitConfiguration];
    [session startRunning];
    for(AVCaptureConnection *connection in videoOutput.connections)
    {
        if(connection.supportsVideoOrientation)
        {
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
    }
    
    CVReturn cvError = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, glView.context, NULL, &textureCache);
    if(cvError)
    {
        [NSException raise:@"" format:@"CVOpenGLESTextureCacheCreate failed"];
    }
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferWidth = CVPixelBufferGetWidth(imageBuffer);
    int bufferHeight = CVPixelBufferGetHeight(imageBuffer);
    
    videoAspect = (float)bufferWidth / (float)bufferHeight;
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    {
        CVOpenGLESTextureRef esTexture;
        CVReturn cvError = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                        textureCache,
                                                                        imageBuffer,
                                                                        NULL,
                                                                        GL_TEXTURE_2D,
                                                                        GL_RGBA,
                                                                        bufferWidth, bufferHeight,
                                                                        GL_BGRA,
                                                                        GL_UNSIGNED_BYTE,
                                                                        0,
                                                                        &esTexture);
        
        if(cvError)
        {
            NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage failed");
        }
        GLuint textureName = CVOpenGLESTextureGetName(esTexture);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, textureName);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        CVOpenGLESTextureCacheFlush(textureCache, 0);
        
        if(textureObject)
            CFRelease(textureObject);
        
        textureObject = esTexture;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

- (void)render:(CADisplayLink *)sender
{
    glClearColor(1.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    float iGlobalTime = [[NSDate date] timeIntervalSinceDate:beginTime];
    GLKVector2 iResolution = {glView.glBufferWidth, glView.glBufferHeight};
    
    [shader setTextureUnit:0 forUniformKey:@"videoInput"];
    [shader setFloat:iGlobalTime forUniformKey:@"iGlobalTime"];
    [shader setVector2:iResolution forUniformKey:@"iResolution"];
    
    [shader bind:^{
        typedef struct{
            GLKVector2 position;
            GLKVector2 texcoord;
        }Vertex;
        
//        Vertex vertices[] =
//        {
//            {{-1.0f,  1.0f}, {0.0f, 1.0f}},
//            {{-1.0f, -1.0f}, {0.0f, 0.0f}},
//            {{ 1.0f, -1.0f}, {1.0f, 0.0f}},
//            {{ 1.0f,  1.0f}, {1.0f, 1.0f}},
//        };
        
        //invert vertical
        Vertex vertices[] =
        {
            {{-1.0f,  1.0f}, {0.0f, 0.0f}},
            {{-1.0f, -1.0f}, {0.0f, 1.0f}},
            {{ 1.0f, -1.0f}, {1.0f, 1.0f}},
            {{ 1.0f,  1.0f}, {1.0f, 0.0f}},
        };
        
        int positionLocation = [shader attribLocationForKey:@"position"];
        int texcoordLocation = [shader attribLocationForKey:@"texcoord"];
        glEnableVertexAttribArray(positionLocation);
        glEnableVertexAttribArray(texcoordLocation);
        glVertexAttribPointer(positionLocation, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), &vertices[0].position);
        glVertexAttribPointer(texcoordLocation, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), &vertices[0].texcoord);
        
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        
        glDisableVertexAttribArray(positionLocation);
        glDisableVertexAttribArray(texcoordLocation);
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
