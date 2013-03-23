#import "GShaderInput.h"

@implementation GShaderInput
{
    GImageShaderInputType _type;
    
    union
    {
        int textureUnit;
        float floatValue;
        GLKVector2 vector2;
        GLKVector3 vector3;
        GLKVector4 vector4;
        GLKMatrix2 matrix2;
        GLKMatrix3 matrix3;
        GLKMatrix4 matrix4;
    }primitive;
}
- (GImageShaderInputType)type
{
    return _type;
}
- (id)initWithTextureUnit:(int)unit
{
    if(self = [super init])
    {
        _type = GSHADER_INPUT_TEXTURE_SLOT;
        primitive.textureUnit = unit;
    }
    return self;
}
- (id)initWithFloat:(float)floatValue
{
    if(self = [super init])
    {
        _type = GSHADER_INPUT_FLOAT;
        primitive.floatValue = floatValue;
    }
    return self;
}
- (id)initWithVector2:(GLKVector2)vector2
{
    if(self = [super init])
    {
        _type = GSHADER_INPUT_VECTOR2;
        primitive.vector2 = vector2;
    }
    return self;
}
- (id)initWithVector3:(GLKVector3)vector3
{
    if(self = [super init])
    {
        _type = GSHADER_INPUT_VECTOR3;
        primitive.vector3 = vector3;
    }
    return self;
}
- (id)initWithVector4:(GLKVector4)vector4
{
    if(self = [super init])
    {
        _type = GSHADER_INPUT_VECTOR4;
        primitive.vector4 = vector4;
    }
    return self;
}
- (id)initWithMatrix2:(GLKMatrix2)matrix2
{
    if(self = [super init])
    {
        _type = GSHADER_INPUT_MATRIX2;
        primitive.matrix2 = matrix2;
    }
    return self;
}
- (id)initWithMatrix3:(GLKMatrix3)matrix3
{
    if(self = [super init])
    {
        _type = GSHADER_INPUT_MATRIX3;
        primitive.matrix3 = matrix3;
    }
    return self;
}
- (id)initWithMatrix4:(GLKMatrix4)matrix4
{
    if(self = [super init])
    {
        _type = GSHADER_INPUT_MATRIX4;
        primitive.matrix4 = matrix4;
    }
    return self;
}

- (int)textureUnitValue
{
    return _type == GSHADER_INPUT_TEXTURE_SLOT? primitive.textureUnit : 0;
}
- (float)floatValue
{
    return _type == GSHADER_INPUT_FLOAT? primitive.floatValue : 0.0f;
}
- (GLKVector2)vector2Value
{
    return _type == GSHADER_INPUT_VECTOR2? primitive.vector2 : GLKVector2Make(0, 0);
}
- (GLKVector3)vector3Value
{
    return _type == GSHADER_INPUT_VECTOR3? primitive.vector3 : GLKVector3Make(0, 0, 0);
}
- (GLKVector4)vector4Value
{
    return _type == GSHADER_INPUT_VECTOR4? primitive.vector4 : GLKVector4Make(0, 0, 0, 0);
}
- (GLKMatrix2)matrix2Value
{
    return _type == GSHADER_INPUT_MATRIX2? primitive.matrix2 : (GLKMatrix2){1, 0, 0, 1};
}
- (GLKMatrix3)matrix3Value
{
    return _type == GSHADER_INPUT_MATRIX3? primitive.matrix3 : GLKMatrix3Identity;
}
- (GLKMatrix4)matrix4Value
{
    return _type == GSHADER_INPUT_MATRIX4? primitive.matrix4 : GLKMatrix4Identity;
}
@end
