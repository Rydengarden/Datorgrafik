find_package (assimp QUIET ${LUGGCGL_ASSIMP_MIN_VERSION})
if (NOT assimp_FOUND)
	FetchContent_Declare (
		assimp
		GIT_REPOSITORY [[https://github.com/assimp/assimp.git]]
		GIT_TAG "v${LUGGCGL_ASSIMP_DOWNLOAD_VERSION}"
		GIT_SHALLOW ON

		PATCH_COMMAND ${GIT_EXECUTABLE} reset --hard HEAD # Remove any existing changes before applying the patch (in case patch is applied twice, for example)
		# assimp will fail to link on Windows without that commit
		# (which is not part of any release as of now).
		COMMAND ${GIT_EXECUTABLE} apply ${CMAKE_SOURCE_DIR}/0001-Fix-CMake-import.patch
		COMMAND ${GIT_EXECUTABLE} apply ${CMAKE_SOURCE_DIR}/0002-Always-set-IMPORTED_CONFIGURATIONS.patch
		COMMAND ${GIT_EXECUTABLE} apply ${CMAKE_SOURCE_DIR}/0003-Fix-dynamic-loading-path-for-OSX.patch
		COMMAND ${GIT_EXECUTABLE} apply ${CMAKE_SOURCE_DIR}/0004-Turn-multi-configuration-off.patch
	)

	FetchContent_GetProperties (assimp)
	if (NOT assimp_POPULATED)
		message (STATUS "Cloning assimp…")
		FetchContent_Populate (assimp)
	endif ()

	set (assimp_INSTALL_DIR "${FETCHCONTENT_BASE_DIR}/assimp-install")
	if (NOT EXISTS "${assimp_INSTALL_DIR}")
		file (MAKE_DIRECTORY ${assimp_INSTALL_DIR})
	endif ()

	message (STATUS "Setting up CMake for assimp…")
	execute_process (
		COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}"
		                         -A "${CMAKE_GENERATOR_PLATFORM}"
		                         -DASSIMP_NO_EXPORT=ON
		                         -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
		                         -DASSIMP_BUILD_TESTS=OFF
		                         -DCMAKE_INSTALL_PREFIX=${assimp_INSTALL_DIR}
		                         -DCMAKE_BUILD_TYPE=Release
		                         ${assimp_SOURCE_DIR}
		OUTPUT_VARIABLE stdout
		ERROR_VARIABLE stderr
		RESULT_VARIABLE result
		WORKING_DIRECTORY ${assimp_BINARY_DIR}
	)
	if (result)
		message (FATAL_ERROR "CMake setup for assimp failed: ${result}\n"
		                     "Standard output: ${stdout}\n"
		                     "Error output: ${stderr}")
	endif ()

	message (STATUS "Building and installing assimp…")
	execute_process (
		COMMAND ${CMAKE_COMMAND} --build ${assimp_BINARY_DIR}
		                         --config Release
		                         --target install
		OUTPUT_VARIABLE stdout
		ERROR_VARIABLE stderr
		RESULT_VARIABLE result
	)
	if (result)
		message (FATAL_ERROR "Build step for assimp failed: ${result}\n"
		                     "Standard output: ${stdout}\n"
		                     "Error output: ${stderr}")
	endif ()

	list (APPEND CMAKE_PREFIX_PATH ${assimp_INSTALL_DIR}/lib/cmake)

	set (assimp_INSTALL_DIR)
endif ()
