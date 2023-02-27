//
//  dataScanner.mm
//  plugin_dataScanner
//
//
#import "dataScanner.h"


#include <CoronaRuntime.h>
#include <CoronaLua.h>
#include <CoronaLibrary.h>
#include <CoronaEvent.h>

#import "plugin_dataScanner-Bridging-Header.h"
#import <VisionKit/VisionKit.h>
#import <Foundation/Foundation.h>
// ----------------------------------------------------------------------------

static scannerHolder * myHolder = [[scannerHolder alloc] init];

class dataScanner
{
	public:
		typedef dataScanner Self;

	public:
		static const char kName[];
		static const char kEvent[];

	protected:
    dataScanner();

	public:
		bool Initialize( CoronaLuaRef listener );

	public:
		CoronaLuaRef GetListener() const { return fListener; }

	public:
		static int Open( lua_State *L );

	protected:
		static int Finalizer( lua_State *L );

	public:
		static Self *ToLibrary( lua_State *L );

	public:
		static int show( lua_State *L );
        static int hide( lua_State *L );
        static int startScanning( lua_State *L );
        static int stopScanning( lua_State *L );
        static int scanningIsSupported( lua_State *L );
        static int scanningIsAvailable( lua_State *L );

	private:
    CoronaLuaRef fListener;
};
// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char dataScanner::kName[] = "plugin.dataScanner";

// This corresponds to the event name, e.g. [Lua] event.name
const char dataScanner::kEvent[] = "plugindataScanner";

dataScanner::dataScanner()
:	fListener( NULL )
{
}

bool
dataScanner::Initialize( CoronaLuaRef listener )
{
	// Can only initialize listener once
	bool result = ( NULL == fListener );

	if ( result )
	{
		fListener = listener;
	}

	return result;
}

int
dataScanner::Open( lua_State *L )
{
	// Register __gc callback
	const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
	CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );

	// Functions in library
	const luaL_Reg kVTable[] =
	{
		{ "show", show },
        { "hide", hide },
        { "startScanning", startScanning },
        { "stopScanning", stopScanning },
        { "scanningIsSupported", scanningIsSupported },
        { "scanningIsAvailable", scanningIsAvailable },

		{ NULL, NULL }
	};

	// Set library as upvalue for each library function
	Self *library = new Self;
	CoronaLuaPushUserdata( L, library, kMetatableName );

	luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack

	return 1;
}

int
dataScanner::Finalizer( lua_State *L )
{
	Self *library = (Self *)CoronaLuaToUserdata( L, 1 );

	CoronaLuaDeleteRef( L, library->GetListener() );

	delete library;

	return 0;
}

dataScanner *
dataScanner::ToLibrary( lua_State *L )
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
	return library;
}

int
dataScanner::show( lua_State *L )
{
    void *platformContext = CoronaLuaGetContext( L );
    id<CoronaRuntime> runtime = (__bridge id<CoronaRuntime>)platformContext;
    
    if (@available(iOS 16, *)) {
        
        DataScannerTest * myTest = [[DataScannerTest alloc] init];
        BOOL scanningSupported = [myTest scanningIsSupported];
        BOOL scanningAvailable = [myTest scanningIsAvailable];
        
        if(not scanningSupported or not scanningAvailable) {
            lua_pushboolean(L, 0);
            return 1;
        }
       
    } else {
        lua_pushboolean(L, 0);
        return 1;
    }
    

    UIViewController *root = runtime.appViewController;
    myHolder.myScanner =[[Scanner alloc]init];
    
    BOOL isHighFrameRateTrackingEnabled = NO;
    BOOL isHighlightingEnabled = NO;
    BOOL recognizesMultipleItems = NO;
    BOOL supportBarCode = NO;
    BOOL supportText = NO;
    
    myHolder.myLuaState=L;
    if(lua_istable(L, 1)){
        lua_getfield(L, 1, "highFrameRateTrackingEnabled");
        if(lua_isboolean(L, -1) && lua_toboolean(L, -1) == true ){
            isHighFrameRateTrackingEnabled = YES;
        }
        lua_pop(L, 1);
        lua_getfield(L, 1, "highlightingEnabled");
        if(lua_isboolean(L, -1) && lua_toboolean(L, -1) == true ){
            isHighlightingEnabled = YES;
        }
        lua_pop(L, 1);
        lua_getfield(L, 1, "recognizesMultipleItems");
        if(lua_isboolean(L, -1) && lua_toboolean(L, -1) == true ){
            recognizesMultipleItems = YES;
        }
        lua_pop(L, 1);
        lua_getfield(L, 1, "barCodeSupport");
        if(lua_isboolean(L, -1) && lua_toboolean(L, -1) == true ){
            supportBarCode = YES;
        }
        lua_pop(L, 1);
        lua_getfield(L, 1, "textSupport");
        if(lua_isboolean(L, -1) && lua_toboolean(L, -1) == true ){
            supportText = YES;
        }
        lua_pop(L, 1);
        lua_getfield(L, 1, "listener");
        if(CoronaLuaIsListener(L, -1, "dataScanner")){
            myHolder.myRef = CoronaLuaNewRef(L, -1);
        }
        lua_pop(L, 1);
        
    }
    
    myHolder.scannerView = [myHolder.myScanner makeUIViewController:isHighFrameRateTrackingEnabled isHighlightingEnabled:isHighlightingEnabled recognizesMultipleItems:recognizesMultipleItems supportBarCode:supportBarCode supportText:supportText];
    [root presentViewController:myHolder.scannerView animated:YES completion:^{
        CoronaLuaNewEvent(myHolder.myLuaState, "dataScanner");
        lua_pushstring(myHolder.myLuaState, "showDataScanner");
        lua_setfield(myHolder.myLuaState, -2, "status");
        CoronaLuaDispatchEvent(myHolder.myLuaState, myHolder.myRef, 0);
    }];

    lua_pushboolean(L, 1);
	return 1;
}

int
dataScanner::hide( lua_State *L )
{
    if(myHolder.scannerView && myHolder.myScanner){
        [myHolder.myScanner stopScanning];
        [myHolder closeDataScanner];
    }
    return 0;
}

int
dataScanner::startScanning( lua_State *L )
{
    if(myHolder.myScanner){
        [myHolder.myScanner startScanning];
    }
    return 0;
}

int
dataScanner::stopScanning( lua_State *L )
{
    if(myHolder.myScanner){
        [myHolder.myScanner stopScanning];
    }
    return 0;
}

int
dataScanner::scanningIsSupported( lua_State *L )
{
    
    DataScannerTest * myTest = [[DataScannerTest alloc] init];
    BOOL scanningSupported = [myTest scanningIsSupported];
    lua_pushboolean(L, scanningSupported ? 1 : 0);
    return 1;

}

int
dataScanner::scanningIsAvailable( lua_State *L )
{
    
    DataScannerTest * myTest = [[DataScannerTest alloc] init];
    BOOL scanningAvailable = [myTest scanningIsAvailable];
    lua_pushboolean(L, scanningAvailable ? 1 : 0);
    return 1;
}

// ----------------------------------------------------------------------------
@implementation scannerHolder
- (void) closeDataScanner{
    if(myHolder.myRef){
        CoronaLuaNewEvent(myHolder.myLuaState, "dataScanner");
        lua_pushstring(myHolder.myLuaState, "closeDataScanner");
        lua_setfield(myHolder.myLuaState, -2, "status");
        CoronaLuaDispatchEvent(myHolder.myLuaState, myHolder.myRef, 0);
    }
    [myHolder.scannerView dismissViewControllerAnimated:YES completion:^{
        myHolder.scannerView = NULL;
    }];
};
- (void) gotText:(NSString*)text{
    if(myHolder.myRef){
        CoronaLuaNewEvent(myHolder.myLuaState, "dataScanner");
        lua_pushstring(myHolder.myLuaState, text.UTF8String);
        lua_setfield(myHolder.myLuaState, -2, "data");
        lua_pushstring(myHolder.myLuaState, "textScan");
        lua_setfield(myHolder.myLuaState, -2, "status");
        CoronaLuaDispatchEvent(myHolder.myLuaState, myHolder.myRef, 0);
    }
};
- (void) gotBarcode:(NSString*)barcode{
    if(myHolder.myRef){
        if(myHolder.myRef){
            CoronaLuaNewEvent(myHolder.myLuaState, "dataScanner");
            lua_pushstring(myHolder.myLuaState, barcode.UTF8String);
            lua_setfield(myHolder.myLuaState, -2, "data");
            lua_pushstring(myHolder.myLuaState, "barcodeScan");
            lua_setfield(myHolder.myLuaState, -2, "status");
            CoronaLuaDispatchEvent(myHolder.myLuaState, myHolder.myRef, 0);
        }
    }
};
@end
CORONA_EXPORT int luaopen_plugin_dataScanner( lua_State *L )
{
	return dataScanner::Open( L );
}
