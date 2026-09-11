import os

from building import *

Import('env')
Import('rtconfig')

# Match the dependency behavior of regular RT-Thread packages.  The FSBL is
# an independent program rather than a source group, so the dependency is
# checked before creating any objects or post-build actions.
fsbl_program = []
if not GetDepend(['PKG_USING_STM32N657xx_FSBL']):
    Return('fsbl_program')

if 'fsbl' not in COMMAND_LINE_TARGETS:
    Return('fsbl_program')

package_dir = GetCurrentDir()
bsp_root = Dir('#').abspath

fsbl_sources = [
    os.path.join(package_dir, 'FSBL', 'Core', 'Src', 'main.c'),
    os.path.join(package_dir, 'FSBL', 'Core', 'Src', 'extmem_manager.c'),
    os.path.join(package_dir, 'FSBL', 'Core', 'Src', 'stm32n6xx_it.c'),
    os.path.join(package_dir, 'FSBL', 'Core', 'Src', 'stm32n6xx_hal_msp.c'),
    os.path.join(package_dir, 'FSBL', 'Core', 'Src', 'system_stm32n6xx_fsbl.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_bsec.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_cortex.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_dma.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_dma_ex.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_exti.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_gpio.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_pwr.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_pwr_ex.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_rcc.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_rcc_ex.c'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Src', 'stm32n6xx_hal_xspi.c'),
    os.path.join(package_dir, 'Middlewares', 'ST', 'STM32_ExtMem_Manager', 'stm32_extmem.c'),
    os.path.join(package_dir, 'Middlewares', 'ST', 'STM32_ExtMem_Manager', 'boot', 'stm32_boot_xip.c'),
    os.path.join(package_dir, 'Middlewares', 'ST', 'STM32_ExtMem_Manager', 'sal', 'stm32_sal_xspi.c'),
    os.path.join(package_dir, 'Middlewares', 'ST', 'STM32_ExtMem_Manager', 'nor_sfdp', 'stm32_sfdp_data.c'),
    os.path.join(package_dir, 'Middlewares', 'ST', 'STM32_ExtMem_Manager', 'nor_sfdp', 'stm32_sfdp_driver.c'),
]

include_paths = [
    os.path.join(package_dir, 'FSBL', 'Core', 'Inc'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Inc'),
    os.path.join(package_dir, 'Drivers', 'STM32N6xx_HAL_Driver', 'Inc', 'Legacy'),
    os.path.join(bsp_root, 'packages', 'CMSIS-Core-latest', 'Include'),
    os.path.join(package_dir, 'Drivers', 'CMSIS', 'Include'),
    os.path.join(package_dir, 'Drivers', 'CMSIS', 'Device', 'ST', 'STM32N6xx', 'Include'),
    os.path.join(package_dir, 'Middlewares', 'ST', 'STM32_ExtMem_Manager'),
    os.path.join(package_dir, 'Middlewares', 'ST', 'STM32_ExtMem_Manager', 'boot'),
    os.path.join(package_dir, 'Middlewares', 'ST', 'STM32_ExtMem_Manager', 'sal'),
    os.path.join(package_dir, 'Middlewares', 'ST', 'STM32_ExtMem_Manager', 'nor_sfdp'),
]

if rtconfig.PLATFORM == 'gcc':
    fsbl_sources.append(os.path.join(
        package_dir, 'MDK-ARM', 'startup_stm32n657xx_fsbl.s'))
elif rtconfig.PLATFORM in ['armcc', 'armclang']:
    fsbl_sources.append(os.path.join(
        package_dir, 'MDK-ARM', 'startup_stm32n657xx_fsbl.c'))
else:
    raise RuntimeError('stm32n657xx_fsbl supports GCC and Arm Compiler only')

# Clone the application environment, then replace the settings that define a
# separate image.  In particular, the FSBL must use its RAM linker script and
# must not inherit APP-only include paths or application preprocessor symbols.
fsbl_env = env.Clone()
fsbl_env.Replace(CPPPATH=include_paths)
fsbl_env.Replace(CPPDEFINES=['USE_HAL_DRIVER', 'STM32N657xx'])

linker_dir = os.path.join(bsp_root, 'board', 'linker_scripts')
if rtconfig.PLATFORM == 'gcc':
    linker_script = os.path.join(linker_dir, 'link_fsbl.ld')
    fsbl_env.Replace(LINKFLAGS=(
        rtconfig.DEVICE + ' -mcpu=cortex-m55 -Wl,--gc-sections '
        '-Wl,-Map="%s",-cref -T"%s" '
        '-static -Wl,--start-group -Wl,--end-group'
    ) % (os.path.join(bsp_root, 'build', 'fsbl', 'stm32n657xx_fsbl.map'), linker_script))
else:
    linker_script = os.path.join(linker_dir, 'link_fsbl.sct')
    fsbl_env.Replace(LINKFLAGS=(
        '--cpu Cortex-M55.fp.sp --info sizes --info totals --info unused '
        '--info veneers --list "%s" --strict --scatter "%s"'
    ) % (os.path.join(bsp_root, 'build', 'fsbl', 'stm32n657xx_fsbl.map'), linker_script))

fsbl_build_dir = os.path.join(bsp_root, 'build', 'fsbl')
fsbl_object_dir = os.path.join(fsbl_build_dir, 'obj')
fsbl_objects = []
for source in fsbl_sources:
    object_name = os.path.splitext(os.path.basename(source))[0] + '.o'
    fsbl_objects.append(fsbl_env.Object(
        os.path.join(fsbl_object_dir, object_name), source))

fsbl_target = os.path.join(fsbl_build_dir, 'stm32n657xx_fsbl.' + rtconfig.TARGET_EXT)
fsbl_program = fsbl_env.Program(fsbl_target, fsbl_objects)
Alias('fsbl', fsbl_program)

# Keep the generated binary in the existing location consumed by
# fsbl/Signing_Programmer.bat.  The build target itself remains under build/ so
# normal SCons cleaning does not touch source-controlled package files.
fsbl_binary = os.path.join(bsp_root, 'fsbl', 'stm32n657xx_fsbl.bin')
if rtconfig.PLATFORM == 'gcc':
    fsbl_env.AddPostAction(
        fsbl_program,
        '%s -O binary $TARGET "%s"' % (rtconfig.OBJCPY, fsbl_binary))
else:
    fsbl_env.AddPostAction(
        fsbl_program,
        [
            'fromelf --bin $TARGET --output "%s"' % fsbl_binary,
            'copy /Y "$TARGET" "%s"' % os.path.join(bsp_root, 'fsbl', 'stm32n657xx_fsbl.axf'),
        ])

Return('fsbl_program')
