#import "GShader.h"
#import "GShaderInput.h"
#import "GMacros.h"

#import <GLKit/GLKit.h>

@implementation GShader
{
    NSMutableDictionary *inputValues;
    unsigned program;
}
+ (id)shaderWithVertexShader:(NSString *)vs fragmentShader:(NSString *)fs error:(out NSError **)error
{
    return [[GShader alloc] initWithVertexShader:vs fragmentShader:fs error:error];
}
- (id)initWithVertexShader:(NSString *)vs fragmentShader:(NSString *)fs error:(out NSError **)error
{
    if(self = [super init])
    {
        inputValues = [NSMutableDictionary dictionary];
        
        
        const char *vsSource = vs.UTF8String;
        const char *fsSource = fs.UTF8String;
        unsigned vsShader = glCreateShader(GL_VERTEX_SHADER);
        unsigned fsShader = glCreateShader(GL_FRAGMENT_SHADER);
        
        program = glCreateProgram();
        
        glShaderSource(vsShader, 1, &vsSource, 0);
        glCompileShader(vsShader);
        
        int vsStatus;
        glGetShaderiv(vsShader, GL_COMPILE_STATUS, &vsStatus);
        if(vsStatus == GL_FALSE)
        {
            char *message;
            GLint logLength;
            
            glGetShaderiv(vsShader, GL_INFO_LOG_LENGTH, &logLength);
            message = malloc(logLength);
            glGetShaderInfoLog(vsShader, logLength, &logLength, message);
            
            NSAssert(0, [NSString stringWithUTF8String:message]);
            free(message);
        }
        
        glShaderSource(fsShader, 1, &fsSource, 0);
        glCompileShader(fsShader);
        
        int fsStatus;
        glGetShaderiv(fsShader, GL_COMPILE_STATUS, &fsStatus);
        if(fsStatus == GL_FALSE)
        {
            char *message;
            GLint logLength;
            
            glGetShaderiv(fsShader, GL_INFO_LOG_LENGTH, &logLength);
            message = malloc(logLength);
            glGetShaderInfoLog(fsShader, logLength, &logLength, message);
            
            *error = [NSError errorWithDomain:[NSString stringWithUTF8String:message]
                                         code:0
                                     userInfo:nil];
            
            free(message);
            goto EndOfInit;
        }
        
        glAttachShader(program, vsShader);
        glAttachShader(program, fsShader);
        glLinkProgram(program);
        
    EndOfInit:
        
        glDetachShader(program, vsShader);
        glDetachShader(program, fsShader);
        glDeleteShader(vsShader);
        glDeleteShader(fsShader);
    }
    return self;
}
- (void)dealloc
{
    glDeleteProgram(program);
}
- (void)setTextureUnit:(int)unit     forUniformKey:(NSString *)key
{
    inputValues[key] = [[GShaderInput alloc] initWithTextureUnit:unit];
}
- (void)setFloat:(float)floatValue     forUniformKey:(NSString *)key
{
    inputValues[key] = [[GShaderInput alloc] initWithFloat:floatValue];
}
- (void)setVector2:(GLKVector2)vector2 forUniformKey:(NSString *)key
{
    inputValues[key] = [[GShaderInput alloc] initWithVector2:vector2];
}
- (void)setVector3:(GLKVector3)vector3 forUniformKey:(NSString *)key
{
    inputValues[key] = [[GShaderInput alloc] initWithVector3:vector3];
}
- (void)setVector4:(GLKVector4)vector4 forUniformKey:(NSString *)key
{
    inputValues[key] = [[GShaderInput alloc] initWithVector4:vector4];
}
- (void)setMatrix2:(GLKMatrix2)matrix2 forUniformKey:(NSString *)key
{
    inputValues[key] = [[GShaderInput alloc] initWithMatrix2:matrix2];
}
- (void)setMatrix3:(GLKMatrix3)matrix3 forUniformKey:(NSString *)key
{
    inputValues[key] = [[GShaderInput alloc] initWithMatrix3:matrix3];
}
- (void)setMatrix4:(GLKMatrix4)matrix4 forUniformKey:(NSString *)key
{
    inputValues[key] = [[GShaderInput alloc] initWithMatrix4:matrix4];
}
- (void)bind:(void(^)(void))blocks
{
    glUseProgram(program);
    
    int textureCount = 0;
    for(NSString *key in inputValues.keyEnumerator)
    {
        GShaderInput *input = inputValues[key];
        int location = glGetUniformLocation(program, key.UTF8String);
        if(location == -1)
        {
            NSLog(@"invalid key : %@", key);
            continue;
        }
        
        switch (input.type) {
            case GSHADER_INPUT_TEXTURE_SLOT:
                glUniform1i(location, input.textureUnitValue);
                textureCount++;
                break;
            case GSHADER_INPUT_FLOAT:
                glUniform1f(location, input.floatValue);
                break;
            case GSHADER_INPUT_VECTOR2:
            {
                GLKVector2 v = input.vector2Value;
                glUniform2f(location, v.x, v.y);
                break;
            }
            case GSHADER_INPUT_VECTOR3:
            {
                GLKVector3 v = input.vector3Value;
                glUniform3f(location, v.x, v.y, v.z);
                break;
            }
            case GSHADER_INPUT_VECTOR4:
            {
                GLKVector4 v = input.vector4Value;
                glUniform4f(location, v.x, v.y, v.z, v.w);
                break;
            }
            case GSHADER_INPUT_MATRIX2:
            {
                GLKMatrix2 m = input.matrix2Value;
                glUniformMatrix2fv(location, 1, GL_FALSE, m.m);
                break;
            }
            case GSHADER_INPUT_MATRIX3:
            {
                GLKMatrix3 m = input.matrix3Value;
                glUniformMatrix3fv(location, 1, GL_FALSE, m.m);
                break;
            }
            case GSHADER_INPUT_MATRIX4:
            {
                GLKMatrix4 m = input.matrix4Value;
                glUniformMatrix4fv(location, 1, GL_FALSE, m.m);
                break;
            }
            default:
                //NOP
                break;
        }
    }
    
    //glActiveTexture(GL_TEXTURE0);
    
    if(blocks)
        blocks();
    
    glUseProgram(0);
}
- (int)attribLocationForKey:(NSString *)key
{
    return glGetAttribLocation(program, key.UTF8String);
}
@end
