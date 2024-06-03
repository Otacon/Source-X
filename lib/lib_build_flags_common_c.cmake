set (ENABLED_SANITIZER FALSE)
if (${USE_ASAN} OR ${USE_MSAN} OR ${USE_LSAN} OR ${USE_UBSAN})
	set (ENABLED_SANITIZER TRUE)
endif()

if (MSVC)
	set (c_compiler_options_common
		/O2 /EHsc /GA /Gw /Gy /GF /GR- /GS-
		$<$<CONFIG:Release>: $<IF:$<BOOL:${RUNTIME_STATIC_LINK}>,/MT,/MD>	$<$<BOOL:${ENABLED_SANITIZER}>:/Zi>>
		$<$<CONFIG:Nightly>: $<IF:$<BOOL:${RUNTIME_STATIC_LINK}>,/MT,/MD>   $<$<BOOL:${ENABLED_SANITIZER}>:/Zi>>
		$<$<CONFIG:Debug>:	 $<IF:$<BOOL:${RUNTIME_STATIC_LINK}>,/MTd,/MDd> $<IF:$<BOOL:${ENABLED_SANITIZER}>,/Zi,/ZI>>
	)
	set (c_linker_options_common
		/NODEFAULTLIB:libcmt
		$<$<CONFIG:Release>: /OPT:REF,ICF /LTCG:ON>
		$<$<CONFIG:Nightly>: /OPT:REF,ICF /LTCG:ON>
		$<$<CONFIG:Debug>:   /DEBUG /LTCG:OFF>
	)

else (MSVC)
	set (c_compiler_options_common
		-pipe -fexceptions -fnon-call-exceptions
		-O3
		$<IF:$<BOOL:${ENABLED_SANITIZER}>,-ggdb3,-s>
	)
	set (c_linker_options_common
	)

	if (${CMAKE_C_COMPILER_ID} STREQUAL GNU)
		set (c_compiler_options_common ${c_compiler_options_common}
			-fno-expensive-optimizations
		)
	endif ()

	#if (${CMAKE_C_COMPILER_ID} STREQUAL Clang)
#endif()

endif()
