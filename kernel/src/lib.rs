#![no_std]
#![no_main]
use core::panic::PanicInfo;
// use core::arch::asm;

struct VGABuffer{
    buffer: *mut u8,
    pos: isize,
}

impl VGABuffer{
    fn new(buffer:*mut u8)-> Self{
        VGABuffer{
            buffer,
            pos: 0,
        }
    }
    fn write(&mut self, message: &[u8]){
        for byte in message.iter(){
            unsafe{
                if *byte == b'\n' {
                    //i am assuming fix width of 160 chars
                    let current_line = self.pos / 160;
                    self.pos = (current_line + 1) * 160;
                    continue;
                }
                *self.buffer.offset(self.pos) = *byte;
                *self.buffer.offset(self.pos + 1) = 0x0f;
            }
            self.pos += 2;
        }
    }

}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[unsafe(no_mangle)]
pub extern "C" fn _start() -> ! {
    let mut vga_buffer = VGABuffer::new(0xb8000 as *mut u8);
    vga_buffer.write(b"\n\n\n\nNebula OS\n");

    loop {}
}