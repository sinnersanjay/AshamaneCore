# Set build-directive (used in core to tell which buildtype we used)
target_compile_definitions(trinity-compile-option-interface
  INTERFACE
    -D_BUILD_DIRECTIVE="$<CONFIG>")

set(GCC_EXPECTED_VERSION 6.3.0)

if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS GCC_EXPECTED_VERSION)
  message(FATAL_ERROR "GCC: TrinityCore requires version ${GCC_EXPECTED_VERSION} to build but found ${CMAKE_CXX_COMPILER_VERSION}")
endif()

# Enable SSE2 optimizations only on x86/x86_64 targets.
# Do not force SSE2 (or define __SSE2__) on other architectures such as ARM.
if(CMAKE_SYSTEM_PROCESSOR MATCHES "i.86|x86_64|AMD64")
  if(PLATFORM EQUAL 32)
    # Required on 32-bit x86 systems to enable SSE2 (standard on x64)
    target_compile_options(trinity-compile-option-interface
      INTERFACE
        -msse2
        -mfpmath=sse)
  endif()

  target_compile_definitions(trinity-compile-option-interface
    INTERFACE
      -DHAVE_SSE2)

  message(STATUS "GCC: SFMT enabled, SSE2 flags enabled on x86/x86_64")
else()
  message(STATUS "GCC: non-x86 target detected (${CMAKE_SYSTEM_PROCESSOR}); SSE2 flags disabled")
endif()

if( WITH_WARNINGS )
  target_compile_options(trinity-warning-interface
    INTERFACE
      -W
      -Wall
      -Wextra
      -Winit-self
      -Winvalid-pch
      -Wfatal-errors
      -Woverloaded-virtual)

  target_compile_options(trinity-warning-interface
    INTERFACE
      -Wno-deprecated-copy) # warning in g3d

  message(STATUS "GCC: All warnings enabled")
endif()

if( WITH_COREDEBUG )
  target_compile_options(trinity-compile-option-interface
    INTERFACE
      -g3)

  message(STATUS "GCC: Debug-flags set (-g3)")
endif()

if (BUILD_SHARED_LIBS)
  target_compile_options(trinity-compile-option-interface
    INTERFACE
      -fPIC
      -Wno-attributes)

  target_compile_options(trinity-hidden-symbols-interface
    INTERFACE
      -fvisibility=hidden)

  # Should break the build when there are TRINITY_*_API macros missing
  # but it complains about missing references in precompiled headers.
  # set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wl,--no-undefined")
  # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wl,--no-undefined")

  message(STATUS "GCC: Enabled shared linking")
endif()
