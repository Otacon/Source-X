SET (TOOLCHAIN 1)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Linux-GNU_common.inc.cmake")

function (toolchain_after_project)
	MESSAGE (STATUS "Toolchain: Linux-GNU-native.cmake.")

	SET(CMAKE_SYSTEM_NAME	"Linux"      PARENT_SCOPE)

	IF (CMAKE_SIZEOF_VOID_P EQUAL 8)
        	MESSAGE (STATUS "Detected 64 bits architecture")
		SET(ARCH_BITS	64	PARENT_SCOPE)
		LINK_DIRECTORIES ("/usr/lib64/mysql" "/usr/lib/x86_64-linux-gnu/mysql")
		SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin-native64"	PARENT_SCOPE)
	ELSE ()
		MESSAGE (STATUS "Detected 32 bits architecture")
		SET(ARCH_BITS	32	PARENT_SCOPE)
		LINK_DIRECTORIES ("/usr/lib/mysql" "/usr/lib/i386-linux-gnu/mysql")
		SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin-native32"	PARENT_SCOPE)
	ENDIF ()
	
endfunction()


function (toolchain_exe_stuff)   
	SET (C_ARCH_OPTS	"-march=native")
	SET (CXX_ARCH_OPTS	"-march=native")

	IF (${ARCH_BITS} EQUAL 64)
		#SET (CMAKE_EXE_LINKER_FLAGS_EXTRA "${CMAKE_EXE_LINKER_FLAGS_EXTRA} \
		#	-Wl,-rpath=/usr/lib64/mysql\
		#	-Wl,-rpath=/usr/lib/x86_64-linux-gnu/mysql"
		#	PARENT_SCOPE)
	ELSE ()
		#SET (CMAKE_EXE_LINKER_FLAGS_EXTRA "${CMAKE_EXE_LINKER_FLAGS_EXTRA} \
		#	-Wl,-rpath=/usr/lib/mysql\
		#	-Wl,-rpath=/usr/lib/i386-linux-gnu/mysql"
		#	PARENT_SCOPE)
	ENDIF ()

	toolchain_exe_stuff_common()
	
	# Propagate variables set in toolchain_exe_stuff_common to the upper scope
	SET (CMAKE_C_FLAGS			"${CMAKE_C_FLAGS} ${C_ARCH_OPTS}"       PARENT_SCOPE)
	SET (CMAKE_CXX_FLAGS        "${CMAKE_CXX_FLAGS} ${CXX_ARCH_OPTS}"	PARENT_SCOPE)
	SET (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}" 			PARENT_SCOPE)
endfunction()
