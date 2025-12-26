#===================================================================
# create X-Y grid.
# Copyright (C) 2025 LogicResearch K.K (Author: MATSUDA Masahiro)
# 
# This script file is licensed under the MIT License.
#===================================================================
module DrawGrid

  include RBA
  
  # =====================================================
  # TOP直下セルに十字線を描く (複数TOP対応)
  # =====================================================
  layer_no = 200
  dt       = 0
  grid_um  = 5.5
  width    = 1
  # ======================


  # fetches current layout view and cell view
  view = RBA::Application.instance.main_window.current_view

  if view.nil?
    puts "Error: No active view."
    exit
  end

  # gets the corresponding layout object
  cellview = view.active_cellview
  layout = cellview.layout

  # レイヤ取得
  layer = layout.layer(layer_no, dt)
  dbu   = layout.dbu
  step  = (grid_um / dbu).to_f

  # LAYER_NO/DT に図形が存在するか判定
  has_shapes = false
  layout.each_cell do |cell|
    has_shapes = true if cell.shapes(layer).size > 0
    break if has_shapes
  end

  # 存在する場合
  if has_shapes
    # shapeを削除
    layout.each_cell do |cell|
      cell.shapes(layer).clear
    end
    puts "Cleared all shapes on layer #{layer_no}/#{dt}"
  
    # GUIレイヤパネルから削除
    layout.delete_layer(layer)
    #view.clear_layers(layer)  
    view.remove_unused_layers()    
    puts "Layer #{layer_no}/#{dt} removed from layout."
    
  else 
  
    # GUI レイヤパネルに追加
    layer_info = RBA::LayerInfo.new(layer_no, dt)
    layout.insert_layer(layer_info) if layout.layer(layer_no, dt).nil?
    view.add_missing_layers
    puts "Layer #{layer_no}/#{dt} added to layout."
  
  
    # shapeの追加
    layout.top_cells.each do |cell|
      bbox = cell.bbox
      x_min, y_min = bbox.left, bbox.bottom
      x_max, y_max = bbox.right, bbox.top

      puts "Top cell: #{cell.name}, bbox=#{bbox}"

      # X方向の罫線
      # 原点を必ず通すため、原点を基準に負方向と正方向に伸ばす
      # 負方向
      x = 0
      while x >= x_min
        cell.shapes(layer).insert(RBA::Path.new([RBA::Point.new(x, y_min), RBA::Point.new(x, y_max)], width))
        x -= step
      end
      # 正方向
      x = step
      while x <= x_max
        cell.shapes(layer).insert(RBA::Path.new([RBA::Point.new(x, y_min), RBA::Point.new(x, y_max)], width))
        x += step
      end

      # Y方向の罫線
      y = 0
      while y >= y_min
        cell.shapes(layer).insert(RBA::Path.new([RBA::Point.new(x_min, y), RBA::Point.new(x_max, y)], width))
        y -= step
      end
      y = step
      while y <= y_max
        cell.shapes(layer).insert(RBA::Path.new([RBA::Point.new(x_min, y), RBA::Point.new(x_max, y)], width))
        y += step
      end
    end
  end


end


