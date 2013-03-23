#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "GShaderInput.h"

typedef NS_ENUM(int, GImageShaderInputType)
{
    GSHADER_INPUT_NONE = 0,
    GSHADER_INPUT_TEXTURE_SLOT,
    GSHADER_INPUT_FLOAT,
    GSHADER_INPUT_VECTOR2,
    GSHADER_INPUT_VECTOR3,
    GSHADER_INPUT_VECTOR4,
    GSHADER_INPUT_MATRIX2,
    GSHADER_INPUT_MATRIX3,
    GSHADER_INPUT_MATRIX4,
};

/*variant type*/
@interface GShaderInput : NSObject
- (id)initWithTextureUnit:(int)unit;
- (id)initWithFloat:(float)floatValue;
- (id)initWithVector2:(GLKVector2)vector2;
- (id)initWithVector3:(GLKVector3)vector3;
- (id)initWithVector4:(GLKVector4)vector4;
- (id)initWithMatrix2:(GLKMatrix2)matrix2;
- (id)initWithMatrix3:(GLKMatrix3)matrix3;
- (id)initWithMatrix4:(GLKMatrix4)matrix4;

- (GImageShaderInputType)type;

- (int)textureUnitValue;
- (float)floatValue;
- (GLKVector2)vector2Value;
- (GLKVector3)vector3Value;
- (GLKVector4)vector4Value;
- (GLKMatrix2)matrix2Value;
- (GLKMatrix3)matrix3Value;
- (GLKMatrix4)matrix4Value;
@end
