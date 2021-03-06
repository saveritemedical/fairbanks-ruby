require 'libusb'
class Scale

  @interface_open = false
  attr_accessor :device, :interface, :endpoint_in, :endpoint_out

  def initialize
    self.device = usb.devices(idVendor: 0x0B67, idProduct: 0x555E, bClass: LIBUSB::CLASS_HID).first
    self.interface = device.interfaces[0]
    (self.endpoint_in, self.endpoint_out) = interface.endpoints
  end

  def usb
    return @usb unless @usb.nil?
    @usb = LIBUSB::Context.new
    @usb.debug = 3
    @usb
  end

  def teardown
    teardown_interface! if @interface_open
    handle.close
    self.handle = nil
  end

  def handle
    @handle ||= device.open
  end

  def handle=(handler)
    @handle = handler
  end

  def get_weight(attr = {})
    setup_interface! unless @interface_open
    begin
      get_weight_safe
    rescue
      get_weight_safe
    end
  end

  private

  def get_weight_safe(attr = {})
    begin
      _get_weight
    rescue
      handle.detach_kernel_driver 0
      _get_weight
    end
  end

  def setup_interface!
    begin
      handle.detach_kernel_driver 0
    rescue
    end
    handle.claim_interface interface
    @interface_open = true
  end

  def teardown_interface!
    handle.release_interface interface
    begin
      handle.attach_kernel_driver interface
    rescue
    end
    @interface_open = false
  end

  def _get_weight
    result = handle.interrupt_transfer(endpoint: endpoint_in, dataIn: 6)
    weight = result[-2..-1].unpack('s').pop
    base = 10 ** result[-3].unpack('c').pop
    (weight * base).to_f
  end

end


