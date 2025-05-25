//Borrowing a randomization function from user Spatial on stackexchange
// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.
uint hash( uint x ) {
    x += ( x << 10u );
    x ^= ( x >>  6u );
    x += ( x <<  3u );
    x ^= ( x >> 11u );
    x += ( x << 15u );
    return x;
}

//take the bits from an int and stuff them into the mantissa of a float
float floatConstruct( uint m ) {
    const uint ieeeMantissa = uint(8388607);; // binary32 mantissa bitmask
    const uint ieeeOne      = uint(1065353216); // 1.0 in IEEE binary32

    m &= ieeeMantissa;                     // Keep only mantissa bits (fractional part)
    m |= ieeeOne;                          // Add fractional part to 1.0

    float  f = uintBitsToFloat( m );       // Range [1:2]
    return f - 1.0;                        // Range [0:1]
}

// Pseudo-random value in half-open range [0:1].
float random( float x ) { return floatConstruct(hash(floatBitsToUint(x))); }
//end of borrowed code

vec2 random1Dto2D(float x){
	return vec2(random(x), random(random(x)));
	}

vec3 random1Dto3D(float x){
	return vec3(random1Dto2D(x), random(random(random(x))));
	}

float random2Dto1D(vec2 xy){
	return random(xy.x + xy.y*3.1415);
}

float random3Dto1D(vec3 xyz){
	return random(xyz.x + xyz.y*3.1415 + xyz.z*2.7818 );
}

vec3 random2Dto3D(vec2 xy){
	return vec3(random1Dto3D(random2Dto1D(xy)));
	}

vec2 random2Dto2D(vec2 xy){
	return random1Dto2D(random2Dto1D(xy));
	}

vec3 random3Dto3D(vec3 xyz){
	return random2Dto3D(vec2(xyz.x + xyz.y*3.1415, xyz.x + xyz.z*2.7818));
	}

vec2 random3Dto2D(vec3 xyz){
	return random2Dto2D(vec2(xyz.x + xyz.y*3.1415, xyz.x + xyz.z*2.7818));
	}