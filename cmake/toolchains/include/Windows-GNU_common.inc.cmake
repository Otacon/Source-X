SET (TOOLCHAIN_LOADED 1)

function (toolchain_force_compiler)
	SET (CMAKE_C_COMPILER 	"gcc" 	CACHE STRING "C compiler" 	FORCE)
	SET (CMAKE_CXX_COMPILER "g++" 	CACHE STRING "C++ compiler" FORCE)
endfunction ()


function (toolchain_after_project_common)
	ENABLE_LANGUAGE(RC)
endfunction ()


function (toolchain_exe_stuff_common)

	#-- Configure the Windows application type.

	IF (${WIN32_SPAWN_CONSOLE})
		SET (CMAKE_EXE_LINKER_FLAGS_EXTRA  ${CMAKE_EXE_LINKER_FLAGS_EXTRA} -mconsole)
		SET (PREPROCESSOR_DEFS_EXTRA	_WINDOWS_CONSOLE)
	#ELSE ()
	#	SET (CMAKE_EXE_LINKER_FLAGS_EXTRA ${CMAKE_EXE_LINKER_FLAGS_EXTRA} -mwindows)
	ENDIF ()


	#-- Validate sanitizers options and store them between the common compiler flags.

	SET (ENABLED_SANITIZER false)
	IF (${USE_ASAN})
		MESSAGE (FATAL_ERROR "MinGW-GCC doesn't yet support ASAN")
		SET (USE_ASAN false)
		#SET (CXX_FLAGS_EXTRA 	${CXX_FLAGS_EXTRA} -fsanitize=address -fsanitize-address-use-after-scope)
		#set (CMAKE_EXE_LINKER_FLAGS_EXTRA 	${CMAKE_EXE_LINKER_FLAGS_EXTRA} -fsanitize=address -static-libasan)
		#SET (ENABLED_SANITIZER true)
	ENDIF ()
	IF (${USE_MSAN})
		MESSAGE (FATAL_ERROR "MinGW-GCC doesn't yet support MSAN")
		SET (USE_MSAN false)
		#SET (CXX_FLAGS_EXTRA 	${CXX_FLAGS_EXTRA} -fsanitize=memory -fsanitize-memory-track-origins=2 -fPIE)
		#set (CMAKE_EXE_LINKER_FLAGS_EXTRA 	${CMAKE_EXE_LINKER_FLAGS_EXTRA} -fsanitize=memory )#-static-libmsan)
		#SET (ENABLED_SANITIZER true)
	ENDIF ()
	IF (${USE_LSAN})
		MESSAGE (FATAL_ERROR "MinGW-GCC doesn't yet support LSAN")
		SET (USE_LSAN false)
		#SET (CXX_FLAGS_EXTRA 	${CXX_FLAGS_EXTRA} -fsanitize=leak)
		#set (CMAKE_EXE_LINKER_FLAGS_EXTRA 	${CMAKE_EXE_LINKER_FLAGS_EXTRA} -fsanitize=leak -static-liblsan)
		#SET (ENABLED_SANITIZER true)
	ENDIF ()
	IF (${USE_UBSAN})
		MESSAGE (FATAL_ERROR "MinGW-GCC doesn't yet support UBSAN")
		SET (USE_UBSAN false)
#		SET (UBSAN_FLAGS
#			-fsanitize=undefined,#shift,integer-divide-by-zero,vla-bound,null,signed-integer-overflow,bounds
#			-fsanitize=float-divide-by-zero,float-cast-overflow,pointer-overflow,unreachable,nonnull-attribute,returns-nonnull-attribute
#			-fno-sanitize=enum)
		#SET (CXX_FLAGS_EXTRA 	${CXX_FLAGS_EXTRA} ${UBSAN_FLAGS} -fsanitize=return,vptr)
		#set (CMAKE_EXE_LINKER_FLAGS_EXTRA 	${CMAKE_EXE_LINKER_FLAGS_EXTRA} -fsanitize=undefined -static-libubsan)
		#SET (ENABLED_SANITIZER true)
	ENDIF ()
	#IF (${ENABLED_SANITIZER})
	#	SET (PREPROCESSOR_DEFS_EXTRA ${PREPROCESSOR_DEFS_EXTRA} _SANITIZERS)
	#ENDIF ()


	#-- Store compiler flags common to all builds.

	set (cxx_local_opts_warnings
		-Wall -Wextra -Wno-nonnull-compare -Wno-unknown-pragmas -Wno-switch -Wno-implicit-fallthrough
		-Wno-parentheses -Wno-format-security -Wno-misleading-indentation -Wno-conversion-null -Wno-unused-result
	)
	set (cxx_local_opts
		-std=c++20 -pthread -fexceptions -fnon-call-exceptions -mno-ms-bitfields
		 # -mno-ms-bitfields is needed to fix structure packing
		 -pipe -ffast-math
	)

	set (cxx_compiler_options_common  ${cxx_local_opts_warnings} ${cxx_local_opts} ${CXX_FLAGS_EXTRA})


	#-- Apply compiler flags, only the ones specific per build type.

	# -fno-omit-frame-pointer disables a good optimization which may corrupt the debugger stack trace.
	SET (COMPILE_OPTIONS_EXTRA)
	IF (ENABLED_SANITIZER OR TARGET spheresvr_debug)
		SET (COMPILE_OPTIONS_EXTRA -fno-omit-frame-pointer -fno-inline)
	ENDIF ()
	IF (TARGET spheresvr_release)
		TARGET_COMPILE_OPTIONS ( spheresvr_release	PUBLIC -s -O3 ${COMPILE_OPTIONS_EXTRA})
	ENDIF ()
	IF (TARGET spheresvr_nightly)
		IF (ENABLED_SANITIZER)
			TARGET_COMPILE_OPTIONS ( spheresvr_nightly	PUBLIC -ggdb3 -O1 ${COMPILE_OPTIONS_EXTRA})
		ELSE ()
			TARGET_COMPILE_OPTIONS ( spheresvr_nightly	PUBLIC -O3 ${COMPILE_OPTIONS_EXTRA})
		ENDIF ()
	ENDIF ()
	IF (TARGET spheresvr_debug)
		TARGET_COMPILE_OPTIONS ( spheresvr_debug	PUBLIC -ggdb3 -Og ${COMPILE_OPTIONS_EXTRA})
	ENDIF ()


	#-- Store common linker flags.

	IF (${USE_MSAN})
		SET (CMAKE_EXE_LINKER_FLAGS_EXTRA	${CMAKE_EXE_LINKER_FLAGS_EXTRA} -pie)
	ENDIF()
	set (cxx_linker_options_common 			${CMAKE_EXE_LINKER_FLAGS_EXTRA} -pthread -dynamic
		$<$<BOOL:${RUNTIME_STATIC_LINK}>:	-static-libstdc++ -static-libgcc> # no way to statically link against libc? maybe we can on windows?
	)


	#-- Store common define macros.

	set (cxx_compiler_definitions_common
		${PREPROCESSOR_DEFS_EXTRA}
		$<$<NOT:$<BOOL:${CMAKE_NO_GIT_REVISION}>>:_GITVERSION>
		 _EXCEPTIONS_DEBUG
		# _EXCEPTIONS_DEBUG: Enable advanced exceptions catching. Consumes some more resources, but is very useful for debug
		#   on a running environment. Also it makes sphere more stable since exceptions are local.
		_CRT_SECURE_NO_WARNINGS
		# _CRT_SECURE_NO_WARNINGS: Temporary setting to do not spam so much in the build proccess while we get rid of -W4 warnings and, after it, -Wall.
		_WINSOCK_DEPRECATED_NO_WARNINGS
		# _WINSOCK_DEPRECATED_NO_WARNINGS: Removing warnings until the code gets updated or reviewed.
	)


	#-- Apply define macros, only the ones specific per build type.

	IF (TARGET spheresvr_release)
		TARGET_COMPILE_DEFINITIONS ( spheresvr_release	PUBLIC NDEBUG THREAD_TRACK_CALLSTACK )
	ENDIF ()
	IF (TARGET spheresvr_nightly)
		TARGET_COMPILE_DEFINITIONS ( spheresvr_nightly	PUBLIC NDEBUG THREAD_TRACK_CALLSTACK _NIGHTLYBUILD )
	ENDIF ()
	IF (TARGET spheresvr_debug)
		TARGET_COMPILE_DEFINITIONS ( spheresvr_debug	PUBLIC _DEBUG THREAD_TRACK_CALLSTACK _PACKETDUMP )
	ENDIF ()


	#-- Now apply the common compiler options, preprocessor macros, linker options.

	foreach(tgt ${TARGETS})
		target_compile_options 		(${tgt} PRIVATE ${cxx_compiler_options_common})
		target_compile_definitions 	(${tgt} PRIVATE ${cxx_compiler_definitions_common})
		target_link_options 		(${tgt} PRIVATE ${cxx_linker_options_common})
		target_link_libraries 		(${tgt} PRIVATE mariadb ws2_32})
	endforeach()



	#-- Set different output folders for each build type
	# (When we'll have support for multi-target builds...)
	#SET_TARGET_PROPERTIES(spheresvr PROPERTIES RUNTIME_OUTPUT_RELEASE	"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Release"	)
	#SET_TARGET_PROPERTIES(spheresvr PROPERTIES RUNTIME_OUTPUT_DEBUG		"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Debug"	)
	#SET_TARGET_PROPERTIES(spheresvr PROPERTIES RUNTIME_OUTPUT_NIGHTLY	"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Nightly"	)

endfunction()
